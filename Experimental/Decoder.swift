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
    func setInput(to inputGenome: Genome) -> ValueParserProtocol
    func setDefaultInput() -> ValueParserProtocol
}

fileprivate enum DecodeState {
    case endOfStrand, inLayer, inNeuron, noLayer
}

class Decoder {
    var inputGenome: Genome!
    let expresser: ExpresserProtocol!
    var parser: ValueParserProtocol!

    init(inputGenome: Genome? = nil, parser: ValueParserProtocol? = nil, expresser: ExpresserProtocol? = nil) {
        // The genomoe can be set or reset at any time
        if let g = inputGenome { self.inputGenome = g }

        if let e = expresser { self.expresser = e }
        else { self.expresser = Expresser().newBrain() }

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
        expresser.reset()

        var slice = inputGenome[inputGenome.startIndex..<inputGenome.endIndex]

        while decodeState != .endOfStrand {
            guard let _ = slice.first else { decodeState = .endOfStrand; break }

            var symbolsConsumed = 0
            switch decodeState {
            case .noLayer: symbolsConsumed = dispatch_noLayer(slice)
            case .inLayer: symbolsConsumed = dispatch_inLayer(slice)
            case .inNeuron: symbolsConsumed = dispatch_inNeuron(slice)
            case .endOfStrand: fatalError("We shouldn't be in here; end-of-strand is how the loop knows to stop.")
            }

            slice = slice.dropFirst(symbolsConsumed)
        }

        expresser.endOfStrand()
    }
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
        case A: expresser.addActivator(parseBool(meatSlice))
        case W: expresser.addWeight(parseDouble(meatSlice))
        case b: expresser.setBias(parseDouble(meatSlice))
        case t: expresser.setThreshold(parseDouble(meatSlice))
        default: fatalError("Looking for a value gene and found something else")
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
            expresser.newLayer()
            return 0
            
        case N:
            decodeState = .inNeuron
            expresser.newLayer()
            expresser.newNeuron()
            return 0

        default:
            decodeState = .inNeuron
            expresser.newLayer()
            expresser.newNeuron()
            
            return dispatchValueGene(slice)
        }
    }
    
    func dispatch_inLayer(_ slice: GenomeSlice) -> Int {
        guard let first = slice.first else { fatalError("Thought we had a slice, but it's gone now?") }
        switch first {
        case L:
            decodeState = .inLayer
            
            expresser.closeLayer()
            expresser.newLayer()
            return 0
            
        case N:
            decodeState = .inNeuron
            expresser.newNeuron()     // Close any open neuron and start a new one
            return 0

        default:
            decodeState = .inNeuron
            return dispatchValueGene(slice)
        }
    }

    func dispatch_inNeuron(_ slice: GenomeSlice) -> Int {
        guard let first = slice.first else { fatalError("Thought we had a slice, but it's gone now?") }
        switch first {
        case L:
            decodeState = .inLayer
            expresser.closeNeuron()
            expresser.closeLayer()
            expresser.newLayer()
            return 0
            
        case N:
            decodeState = .inNeuron
            expresser.closeNeuron()
            expresser.newNeuron()
            return 0
            
        default:
            return dispatchValueGene(slice)
        }
    }
}

extension Decoder: ValueParserProtocol {
    func setInput(to inputGenome: Genome) -> ValueParserProtocol {
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
