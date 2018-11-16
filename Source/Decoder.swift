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

protocol ValueParserProtocol {
    func parseBool(_ slice: GenomeSlice?) -> Bool
    func parseDouble(_ slice: GenomeSlice?) -> Double
    func parseInt(_ slice: GenomeSlice?) -> Int
    func setDefaultInput() -> ValueParserProtocol
}

fileprivate enum DecodeState {
    case endOfStrand, inLayer, inNeuron, noLayer
}

class Decoder {
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

    func decode() {
        self.reset()
        Expresser.e.reset()
        
        let head: Genome = {
            var g = Genome(); g += "R.L."; for _ in 0..<5 { g += "N.A(true).W(1)." }; return g
        }()
        
        let tail: Genome = {
            var g = Genome(); g += "L."; for _ in 0..<9 { g += "N.A(true).W(1)." }; return g
        }()

        var slice = head[...] + inputGenome[...] + tail[...]

        while decodeState != .endOfStrand {
            if slice.first == nil { decodeState = .endOfStrand; break }

            var symbolsConsumed = 0
            switch decodeState {
            case .noLayer: symbolsConsumed = dispatch_noLayer(slice)
            case .inLayer: symbolsConsumed = dispatch_inLayer(slice)
            case .inNeuron: symbolsConsumed = dispatch_inNeuron(slice)
            case .endOfStrand: fatalError("We shouldn't be in here; end-of-strand is how the loop knows to stop.")
            }

            slice = slice.dropFirst(symbolsConsumed)
        }

        Expresser.e.endOfStrand()
    }
    
    func newBrain() { Expresser.e.newBrain() }
    
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
        case A: Expresser.e.addActivator(parseBool(meatSlice))
        case W: Expresser.e.addWeight(parseDouble(meatSlice))
        case b: Expresser.e.setBias(parseDouble(meatSlice))
        case t: Expresser.e.setThreshold(parseDouble(meatSlice))
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
            Expresser.e.newLayer()
            return 2
            
        case N:
            decodeState = .inNeuron
            Expresser.e.newLayer()
            Expresser.e.newNeuron()
            return 2

        default:
            decodeState = .inNeuron
            Expresser.e.newLayer()
            Expresser.e.newNeuron()
            
            return dispatchValueGene(slice)
        }
    }
    
    func dispatch_inLayer(_ slice: GenomeSlice) -> Int {
        guard let first = slice.first else { fatalError("Thought we had a slice, but it's gone now?") }
        switch first {
        case L:
            decodeState = .inLayer
            
            Expresser.e.closeLayer()
            Expresser.e.newLayer()
            return 2
            
        case N:
            decodeState = .inNeuron
            Expresser.e.newNeuron()
            return 2

        default:
            decodeState = .inNeuron
            Expresser.e.newNeuron()
            return dispatchValueGene(slice)
        }
    }

    func dispatch_inNeuron(_ slice: GenomeSlice) -> Int {
        guard let first = slice.first else { fatalError("Thought we had a slice, but it's gone now?") }
        switch first {
        case L:
            decodeState = .inLayer
            Expresser.e.closeNeuron()
            Expresser.e.closeLayer()
            Expresser.e.newLayer()
            return 2
            
        case N:
            decodeState = .inNeuron
            Expresser.e.closeNeuron()
            Expresser.e.newNeuron()
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
