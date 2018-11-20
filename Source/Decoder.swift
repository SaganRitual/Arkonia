//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

import Foundation

fileprivate enum DecodeState {
    case diagnostics, endOfStrand, inLayer, inNeuron, noLayer
}

class Decoder {
    static var d: Decoder!

    enum BirthDefect: Error {
        case emptyLayer
    }

    var inputGenome: Genome!
    var parser: ValueParserProtocol!

    init() {
        // The genomoe can be set or reset at any time.
        // Here, if the caller hasn't specified an input
        // genome, then we just sit idle until we get
        // further instructions
        if let g = inputGenome { self.inputGenome = g }

        if let p = parser { self.parser = p }
        else { self.parser = self }
        
        Decoder.d = self
    }
    
    var A: Character { return "A" } // Activator -- Bool
    var B: Character { return "B" } // Generic Bool
    var D: Character { return "D" } // Generic Double
    var H: Character { return "H" } // Hox gene
    var I: Character { return "I" } // Generic Int
    var L: Character { return "L" } // Layer
    var N: Character { return "N" } // Neuron
    var W: Character { return "W" } // Weight -- Double
    var b: Character { return "b" } // bias as Double
    var t: Character { return "t" } // threshold as Double

    fileprivate var decodeState: DecodeState = .noLayer
    let recognizedGeneTokens = "ABDILNWbt"

    func decode() {
        self.reset()
        Translators.t.reset()
        Translators.t.newBrain()
        
        var slice = Utilities.applyInterfaces(to: inputGenome)
        
        let skipBadTokens = { (_ slice: GenomeSlice) -> GenomeSlice.Index in
            if let r = slice.firstIndex(where: { return self.recognizedGeneTokens.contains($0) }) {
                return r
            } else {
                self.decodeState = .endOfStrand
            }
            
            return slice.startIndex
        }
        
        let discardAnyGarbage = { (_ slice: GenomeSlice) -> GenomeSlice.Index in
            guard let s = slice.first else { return slice.endIndex }
            
            if self.recognizedGeneTokens.contains(s) { return slice.startIndex }
            else { return skipBadTokens(slice) }
        }

        while decodeState != .endOfStrand {
            // Just ignore any unrecognized characters, in case I screw up the data
            let nextValidTokenIndex = slice.startIndex
            let goodDataIndex = discardAnyGarbage(slice)
            if goodDataIndex == slice.endIndex { decodeState = .endOfStrand; break }
            if goodDataIndex != nextValidTokenIndex { slice = slice[goodDataIndex...] }

            var symbolsConsumed = 0
            switch decodeState {
                // Skip the diagnostics, or the decoder will create
                // a nice new layer for us, with a single neuron
            case .diagnostics: symbolsConsumed = dispatch_noLayer(slice)
            case .noLayer: symbolsConsumed = dispatch_noLayer(slice)
            case .inLayer: symbolsConsumed = dispatch_inLayer(slice)
            case .inNeuron: symbolsConsumed = dispatch_inNeuron(slice)
            case .endOfStrand: break;
            }

            slice = slice.dropFirst(symbolsConsumed)
        }

        Translators.t.endOfStrand()
    }
    
    func newBrain() { Translators.t.newBrain() }
    
    func reset() { self.decodeState = .noLayer }
}

extension Decoder {
    func dispatchValueGene(_ slice: GenomeSlice) -> Int {
        var symbolsConsumed = 0
        var tSlice = slice
        let token = tSlice.first!

        symbolsConsumed += 2; tSlice = tSlice.dropFirst(2)
        
        let ixOfCloseParen = tSlice.firstIndex(of: ")")!
        let meatSlice = tSlice[..<ixOfCloseParen]
        
        switch token {
        case A: Translators.t.addActivator(parseBool(meatSlice))
        case W: Translators.t.addWeight(parseDouble(meatSlice))
        case b: Translators.t.setBias(parseDouble(meatSlice))
        case t: Translators.t.setThreshold(parseDouble(meatSlice))
        default: print("Decoder says '\(token)' is an unknown token: "); return 2
        }

        symbolsConsumed += 2 + tSlice.distance(from: tSlice.startIndex, to: ixOfCloseParen)
        return symbolsConsumed
    }
}

extension Decoder {
    
    func dispatch_noLayer(_ slice: GenomeSlice) -> Int {
        guard let first = slice.first else { fatalError("Thought we had a slice, but it's gone now?") }
        switch first {
        case L:
            decodeState = .inLayer
            Translators.t.newLayer()
            return 2
            
        case N:
            decodeState = .inNeuron
            Translators.t.newLayer()
            Translators.t.newNeuron()
            return 2
            
        case "R":
            decodeState = .noLayer
            return 2

        default:
            decodeState = .inNeuron
            Translators.t.newLayer()
            Translators.t.newNeuron()
            
            return dispatchValueGene(slice)
        }
    }
    
    func dispatch_inLayer(_ slice: GenomeSlice) -> Int {
        guard let first = slice.first else { fatalError("Thought we had a slice, but it's gone now?") }
        switch first {
        case L:
            // Got another layer marker, but it would
            // cause this one to be empty. Just ignore it.
            decodeState = .inLayer
            return 2
            
        case N:
            decodeState = .inNeuron
            Translators.t.newNeuron()
            return 2

        default:
            decodeState = .inNeuron
            Translators.t.newNeuron()
            return dispatchValueGene(slice)
        }
    }

    func dispatch_inNeuron(_ slice: GenomeSlice) -> Int {
        guard let first = slice.first else { fatalError("Thought we had a slice, but it's gone now?") }
        switch first {
        case L:
            decodeState = .inLayer
            Translators.t.closeNeuron()
            Translators.t.closeLayer()
            Translators.t.newLayer()
            return 2
            
        case N:
            decodeState = .inNeuron
            Translators.t.closeNeuron()
            Translators.t.newNeuron()
            return 2
            
        default:
            return dispatchValueGene(slice)
        }
    }
}

extension Decoder: ValueParserProtocol {
    func setInput(to inputGenome: Genome) -> Decoder {
        self.inputGenome = inputGenome
        return self
    }
    
    func setDefaultInput() -> ValueParserProtocol { return self }

    func parse<PrimitiveType>(_ slice: GenomeSlice? = nil) -> PrimitiveType {
        fatalError("Should never come here")
    }
    
    func parseBool(_ slice: GenomeSlice? = nil) -> Bool {
        let truthy = "true", falsy = "false", stringy = String(slice!)
        switch stringy {
        case truthy: return true
        case falsy:  return false
        default: fatalError("Bad data! You said it would never be bad.")
        }
    }
    
    func parseDouble(_ slice: GenomeSlice? = nil) -> Double {
        let s = String(slice!)
        let n = NSNumber(floatLiteral: Double(s)!)
        return Double(truncating: n)
    }
    
    func parseInt(_ slice: GenomeSlice? = nil) -> Int { return Int(slice!)! }
}
