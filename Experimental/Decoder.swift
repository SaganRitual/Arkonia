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

enum DecodeError: Error {
    case earlyEndOfDecodeUnit, fatal, general, inputInconsistent, overshot, recoverable
}

fileprivate enum DecodeState {
    case endOfStrand, inLayer, inNeuron, noLayer
}

class Decoder {
    var inputStrand: Strand!
    let parsers: ValueParserProtocol
    let translators: GeneDecoderProtocol

    init(parsers: ValueParserProtocol, translators: GeneDecoderProtocol) {
        self.parsers = parsers
        self.translators = translators
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
        translators.reset()

        var slice = inputStrand[inputStrand.startIndex..<inputStrand.endIndex]

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

        translators.endOfStrand()
    }
}

extension Decoder {
    func dispatchValueGene(_ slice: StrandSlice) -> Int {
        var symbolsConsumed = 0
        var tSlice = slice
        let token = tSlice.first!

        symbolsConsumed += 2; tSlice = tSlice.dropFirst(2)
        
        let ixOfCloseParen = tSlice.firstIndex(of: ")")!
        let meatSlice = tSlice[..<ixOfCloseParen]
        
        switch token {
        case A: translators.addActivator(parseBool(meatSlice))
        case W: translators.addWeight(parseDouble(meatSlice))
        case b: translators.setBias(parseDouble(meatSlice))
        case t: translators.setThreshold(parseDouble(meatSlice))
        default: fatalError("Looking for a value gene and found something else")
        }

        symbolsConsumed += 2 + tSlice.distance(from: tSlice.startIndex, to: ixOfCloseParen)
        return symbolsConsumed
    }
}

extension Decoder {
    
    func dispatch_noLayer(_ slice: StrandSlice) -> Int {
        guard let first = slice.first else { fatalError("Though we had a slice, but it's gone now?") }
        switch first {
        case L:
            decodeState = .inLayer
            translators.newLayer()
            return 0
            
        case N:
            decodeState = .inNeuron
            translators.newLayer()
            translators.newNeuron()
            return 0

        default:
            decodeState = .inNeuron
            translators.newLayer()
            translators.newNeuron()
            
            return dispatchValueGene(slice)
        }
    }
    
    func dispatch_inLayer(_ slice: StrandSlice) -> Int {
        guard let first = slice.first else { fatalError("Though we had a slice, but it's gone now?") }
        switch first {
        case L:
            decodeState = .inLayer
            
            translators.closeLayer()
            translators.newLayer()
            return 0
            
        case N:
            decodeState = .inNeuron
            translators.newNeuron()     // Close any open neuron and start a new one
            return 0

        default:
            decodeState = .inNeuron
            return dispatchValueGene(slice)
        }
    }

    func dispatch_inNeuron(_ slice: StrandSlice) -> Int {
        guard let first = slice.first else { fatalError("Though we had a slice, but it's gone now?") }
        switch first {
        case L:
            decodeState = .inLayer
            translators.closeNeuron()
            translators.closeLayer()
            translators.newLayer()
            return 0
            
        case N:
            decodeState = .inNeuron
            translators.closeNeuron()
            translators.newNeuron()
            return 0
            
        default:
            return dispatchValueGene(slice)
        }
    }
}

extension Decoder: ValueParserProtocol {
    func setDecoder(decoder: ValueParserProtocol) {
    }
    
    func setInput(to inputStrand: String) -> ValueParserProtocol {
        self.inputStrand = inputStrand
        return self
    }
    
    func setDefaultInput() -> ValueParserProtocol { return self }

    func parse<PrimitiveType>(_ slice: StrandSlice? = nil) -> PrimitiveType {
        fatalError("Should never come here")
    }
    
    func parseBool(_ slice: StrandSlice? = nil) -> Bool {
        let truthy = "true", falsy = "false", stringy = String(slice!)
        switch stringy {
        case truthy: return true
        case falsy:  return false
        default: fatalError("Bad data! You said it would never be bad.")
        }
    }
    
    func parseDouble(_ slice: StrandSlice? = nil) -> Double {
        let s = String(slice!)
        let n = NSNumber(floatLiteral: Double(s)!)
        return Double(truncating: n)
    }
    
    func parseInt(_ slice: StrandSlice? = nil) -> Int { return Int(slice!)! }
}
