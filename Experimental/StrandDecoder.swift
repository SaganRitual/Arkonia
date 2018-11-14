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

class StrandDecoder {
    var inputStrand: Strand!
    let parsers: ValueParserProtocol
    let translators: GeneDecoderProtocol

    init(parsers: ValueParserProtocol, translators: GeneDecoderProtocol) {
        self.parsers = parsers
        self.translators = translators
    }
    
    func decode() {
        var numberOfNeuronsToSeek = 0
        var numberOfNeuronsFound = 0
        var numberOfActivatorsToSeek = 0
        var numberOfActivatorsFound = 0
        var numberOfWeightsToSeek = 0
        var numberOfWeightsFound = 0
        var decodeState: DecodeState = .seekingLayer
        
        enum DecodeState {
            case seekingLayer, seekingNeuron
            case seekingNeuronCount, seekingActivatorsCount, seekingWeightsCount
            case seekingBias, seekingThreshold
            case seekingWeight, seekingActivator
            case endOfStrand
        }
        
        translators.reset()

        var slice = inputStrand[inputStrand.startIndex..<inputStrand.endIndex]
        
        guard let firstIndex = slice.firstIndex(of: L) else { translators.endOfStrand(); return }
        
        var ixOfCloseParen = firstIndex

        while decodeState != .endOfStrand {
            print(decodeState)
            if slice.isEmpty {break}
            switch decodeState {
            case .endOfStrand: break
                
            case .seekingLayer: // We WERE seeking Layer, now we've found it
                slice = slice.dropFirst(2); decodeState = .seekingNeuronCount
                translators.addLayer()
                numberOfNeuronsFound = 0
                if slice.count == 0 { decodeState = .endOfStrand; translators.endOfStrand(); break }
                
            case .seekingNeuronCount: // We WERE seeking neuron count, now we've found it
                slice = slice.dropFirst(2); decodeState = .seekingNeuron

                if let f = slice.first {
                    if f == ")" { ixOfCloseParen = slice.startIndex }
                    else { ixOfCloseParen = slice.firstIndex(of: ")")! }
                } else {
                    decodeState = .endOfStrand
                    translators.endOfStrand(); break
                }
                

                numberOfNeuronsToSeek = parsers.parseInt(slice[..<ixOfCloseParen])

                slice = slice[ixOfCloseParen...]

                slice = slice.dropFirst(2)   // Skip past closing paren and trailing dot, to the next token
                if slice.count == 0 { decodeState = .endOfStrand; translators.endOfStrand(); break }

                // Zero neuron count; we can't do anything with any of the data between
                // here and the next neuron.
                if numberOfNeuronsToSeek == 0 { decodeState = .seekingLayer; continue }

            case .seekingNeuron:
                slice = slice.dropFirst(2); decodeState = .seekingActivatorsCount
                numberOfActivatorsFound = 0; numberOfWeightsFound = 0
                numberOfNeuronsFound += 1
                
                translators.addNeuron()

                if slice.count == 0 { decodeState = .endOfStrand; translators.endOfStrand(); break }

                if numberOfActivatorsFound == numberOfActivatorsToSeek {
                    decodeState = (numberOfWeightsToSeek == 0) ? .seekingBias : .seekingWeight
                } else {
                    decodeState = .seekingActivator
                }

            case .seekingActivatorsCount:
                slice = slice.dropFirst(2); decodeState = .seekingWeightsCount
                ixOfCloseParen = slice.firstIndex(of: ")")!
                numberOfActivatorsToSeek = parsers.parseInt(slice[..<ixOfCloseParen])
                
                slice = slice[ixOfCloseParen...]
                slice = slice.dropFirst(2)   // Skip past trailing dot, to the next token
                if slice.count == 0 { decodeState = .endOfStrand; translators.endOfStrand(); break }

            case .seekingWeightsCount:
                slice = slice.dropFirst(2)
                decodeState = (numberOfActivatorsToSeek == 0) ? .seekingWeight : .seekingActivator
                
                ixOfCloseParen = slice.firstIndex(of: ")")!
                numberOfWeightsToSeek = parsers.parseInt(slice[..<ixOfCloseParen])
                slice = slice[ixOfCloseParen...]

                slice = slice.dropFirst(2)   // Skip past trailing dot, to the next token
                if slice.count == 0 { decodeState = .endOfStrand; translators.endOfStrand(); break }

            case .seekingActivator:
                slice = slice.dropFirst(2)
                numberOfActivatorsFound += 1
                
                if numberOfActivatorsFound == numberOfActivatorsToSeek {
                    decodeState = (numberOfWeightsToSeek == 0) ? .seekingBias : .seekingWeight
                } else {
                    decodeState = .seekingActivator
                }
                
                ixOfCloseParen = slice.firstIndex(of: ")")!
                let activator = parsers.parseBool(slice[..<ixOfCloseParen])
                translators.addActivator(activator)

                slice = slice[ixOfCloseParen...]
                slice = slice.dropFirst(2)   // Skip past trailing dot, to the next token
                if slice.count == 0 { decodeState = .endOfStrand; translators.endOfStrand(); break }

            case .seekingWeight:
                slice = slice.dropFirst(2)
                numberOfWeightsFound += 1

                if numberOfWeightsFound == numberOfWeightsToSeek {
                    decodeState = .seekingBias
                } else {
                    decodeState = .seekingWeight
                }
                
                ixOfCloseParen = slice.firstIndex(of: ")")!
                let weight = parsers.parseDouble(slice[..<ixOfCloseParen])
                translators.addWeight(weight)

                slice = slice[..<ixOfCloseParen]
                slice = slice.dropFirst(2)   // Skip past trailing dot, to the next token
                if slice.count == 0 { decodeState = .endOfStrand; translators.endOfStrand(); break }

            case .seekingBias:
                slice = slice.dropFirst(2); decodeState = .seekingThreshold
                
                ixOfCloseParen = slice.firstIndex(of: ")")!
                let bias = parsers.parseDouble(slice[..<ixOfCloseParen])
                translators.setBias(bias)

                slice = slice[..<ixOfCloseParen]
                slice = slice.dropFirst(2)   // Skip past trailing dot, to the next token
                if slice.count == 0 { decodeState = .endOfStrand; translators.endOfStrand(); break }

            case .seekingThreshold:
                slice = slice.dropFirst(2); decodeState = .seekingLayer
                let threshold = parsers.parseDouble(slice[..<ixOfCloseParen])
                translators.setThreshold(threshold)
                if numberOfNeuronsFound == numberOfNeuronsToSeek {
                    decodeState = .seekingLayer
                } else {
                    decodeState = .seekingNeuron
                }

                slice = slice[..<ixOfCloseParen]
                slice = slice.dropFirst(2)   // Skip past trailing dot, to the next token
                if slice.count == 0 { decodeState = .endOfStrand; translators.endOfStrand(); break }
            }
        }
        
        print("Decode complete; end-of-strand reached: \(translators.reachedEndOfStrand)")
    }
}

extension StrandDecoder: ValueParserProtocol {
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
