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

var B: Character { return Utilities.B[Utilities.B.startIndex] }
var D: Character { return Utilities.D[Utilities.D.startIndex] }
var I: Character { return Utilities.I[Utilities.I.startIndex] }
var L: Character { return Utilities.L[Utilities.L.startIndex] }
var N: Character { return Utilities.N[Utilities.N.startIndex] }
var b: Character { return Utilities.b[Utilities.b.startIndex] }
var t: Character { return Utilities.t[Utilities.t.startIndex] }

let originalStrands = StrandBuilder.buildBrainStrands(howMany: 1)
let originalStrand = originalStrands[0]

struct Neuron {
    let activators: [Bool]
    let weights: [Double]
    let bias: Double
    let threshold: Double
}

struct Layer {
    let neurons: [Neuron]
}

struct Brain {
    let layers: [Layer]
}

let s = originalStrand

var boolCursor   = StrandIterator(input: s, token: B)
var doubleCursor = StrandIterator(input: s, token: D)
var intCursor    = StrandIterator(input: s, token: I)
var layerCursor  = StrandIterator(input: s, token: L)
var neuronCursor = StrandIterator(input: s, token: N)

enum DecodeError: Error {
    case earlyEndOfDecodeUnit, fatal, general, inputInconsistent, overshot, recoverable
}

extension StrandSlice {
    func addIx(_ stringIndex: String.Index, _ ss: Int) -> String.Index {
        return self.index(stringIndex, offsetBy: ss)
    }
    
    func addInt(_ stringIndex: String.Index, _ ss: Int) -> Int {
        return self.distance(from: stringIndex, to: addIx(stringIndex, ss))
    }
    
    func distance(to endIndex: String.Index) -> Int {
        return self.distance(from: self.startIndex, to: endIndex)
    }
    
    func toIndex(_ ss: Int) -> StrandIndex {
        return self.index(self.startIndex, offsetBy: ss)
    }
    
    func toInt(_ index: StrandIndex) -> Int {
        return self.distance(from: self.startIndex, to: index)
    }

    func toString() -> String {
        return String(self)
    }
}

class StrandDecoder {
    let inputStrand: Strand
    
    init(_ inputStrand: Strand) {
        self.inputStrand = inputStrand
    }

    func getDouble(_ slice: StrandSlice) -> (Double, StrandIndex)? {
        print(D)
        
        // Fatal, almost certainly a bug in my code
        guard slice[slice.startIndex] == D else {
            fatalError("Expected D-marker at index \(toInt(slice.startIndex)); slice = \(toString(slice))")
        }
        
        var doubleSlice = slice.dropFirst(2)    // Skip the D-marker and the paren
        
        // Not fatal, it just means there's no double where we
        // expected one. The neuron may be salvageable. There
        // must be at least two characters available: at least
        // one digit, and the closing paren.
        guard doubleSlice.count >= 2 else { return nil }
        
        var ixOfCloseParen = doubleSlice.endIndex
        if let ix = doubleSlice.firstIndex(where: { $0 == ")" }) {
            ixOfCloseParen = ix
        }
        
        let ixOfNextSymbol = (ixOfCloseParen < doubleSlice.endIndex) ?
            addIx(ixOfCloseParen, 1) : ixOfCloseParen
        
        doubleSlice = doubleSlice[..<ixOfCloseParen]
        
        guard let rawDouble = Double(doubleSlice) else { return nil }
        
        return (Double(truncating: NSNumber(floatLiteral: rawDouble)), ixOfNextSymbol)
    }

    func addIx(_ stringIndex: String.Index, _ ss: Int) -> String.Index {
        return self.inputStrand.index(stringIndex, offsetBy: ss)
    }
    
    func addInt(_ stringIndex: String.Index, _ ss: Int) -> Int {
        return self.inputStrand.distance(from: stringIndex, to: addIx(stringIndex, ss))
    }
    
    func distance(to endIndex: String.Index) -> Int {
        return self.inputStrand.distance(from: self.inputStrand.startIndex, to: endIndex)
    }
    
    func gt(_ lhs: StrandIndex, _ rhs: StrandIndex) -> Bool {
        return lhs > rhs
    }
    
    func sub(_ lhs: StrandIndex, from rhs: Int) -> Int {
        return rhs - toInt(lhs)
    }
    
    func toIndex(_ ss: Int) -> StrandIndex {
        return self.inputStrand.index(self.inputStrand.startIndex, offsetBy: ss)
    }
    
    func toInt(_ index: StrandIndex) -> Int {
        return self.inputStrand.distance(from: self.inputStrand.startIndex, to: index)
    }
    
    func toString(_ slice: StrandSlice) -> String {
        return String(slice)
    }
}

func makeSlice(_ string: String, _ startIndex: Int, _ endIndex: Int) -> StrandSlice {
    let rangeStart = string.index(string.startIndex, offsetBy: startIndex)
    let rangeEnd = string.index(string.startIndex, offsetBy: endIndex)
    return string[rangeStart..<rangeEnd]
}

func makeSlice(_ string: String, _ startIndex: StrandIndex, _ rangeEnd: Int) -> StrandSlice {
    print("?", string, rangeEnd, string.distance(from: string.startIndex, to: startIndex))
    let endIndex = string.index(startIndex, offsetBy: rangeEnd)
    return string[startIndex..<endIndex]
}

func makeSlice(_ slice: StrandSlice, _ startIndex: StrandIndex, _ rangeEnd: Int) -> StrandSlice {
    let endIndex = slice.index(startIndex, offsetBy: rangeEnd)
    return slice[startIndex..<endIndex]
}

class TestGetDouble {
    var inputStrand: Strand
    
    init(_ inputStrand: Strand) {
        self.inputStrand = inputStrand
    }

    func testGetDouble() {
        let decoder = StrandDecoder(inputStrand)
        
        let ixOfFirstDouble = inputStrand.firstIndex(of: D)!
        
        // Start with garbagey stuff with a D at the beginning
        for ixLoop in 1..<2 {
            let endIndex = decoder.addIx(ixOfFirstDouble, ixLoop)
            let slice = self.inputStrand[ixOfFirstDouble..<endIndex]
            
            if let (theDouble, _) = decoder.getDouble(slice) {
                let e = "Should get nil, should not be here; ix = \(ixLoop), double = \(theDouble), slice = \(decoder.toString(slice))"
                print(e)
                fatalError(e)
            }
        }
        
        // Lengthen the slice slowly and watch that we get the right value back
        for ixLoop in 5..<10 {
            let slice = makeSlice(self.inputStrand, ixOfFirstDouble, ixLoop)
            if let (double, newEndIndex) = decoder.getDouble(slice) {
                var truncated_ = NSNumber(floatLiteral: 0)
                switch ixLoop {
                case 5: truncated_ = 441
                case 6: truncated_ = 441
                case 7: truncated_ = 441.3
                default: truncated_ = 441.33
                }
                
                let truncated = Double(truncating: truncated_)
                if double != truncated {
                    let e = "Should get \(truncated) here; got \(double), ixLoop = \(ixLoop)"
                    print(e)
                    fatalError(e)
                }
                
                let endss = slice.toInt(newEndIndex)
                if endss != ixLoop && ixLoop <= 9 {
                    let e = "Returned invalid new index \(endss)"
                    print(e)
                    fatalError(e)
                }
            } else {
                let e = "Should get a double here; ixLoop = \(ixLoop), slice = \(slice.toString())"
                print(e)
                fatalError(e)
            }
        }
        
        // Lengthen the slice out to the end of the strand and make sure we
        // get the correct new index
        let tailLength = decoder.sub(ixOfFirstDouble, from: self.inputStrand.count)
        for ixLoop in 1..<tailLength {
            let slice = makeSlice(self.inputStrand, ixOfFirstDouble, ixLoop)

            if let (double, newEndIndex) = decoder.getDouble(slice) {
                var truncated = 0.0
                switch ixLoop {
                case 3: truncated = Double(truncating: 4)
                case 4: truncated = Double(truncating: 44)
                case 5: truncated = Double(truncating: 441)
                case 6: truncated = Double(truncating: 441)
                case 7: truncated = Double(truncating: 441.3)
                default: if ixLoop < 3 { truncated = 0 } else { truncated = Double(truncating: 441.33) }
                }
                
                if double != truncated {
                    let e = "Should get \(truncated) here; got \(double), ixLoop = \(ixLoop), newEix = \(decoder.toInt(newEndIndex))"
                    print(e)
                    fatalError(e)
                }
                
                let endss = slice.toInt(newEndIndex)
                if endss > 9 {
                    let e = "Returned invalid new index \(endss); slice length = \(slice.count)"
                    print(e)
                    fatalError(e)
                }
            } else {
                if ixLoop < 8 { continue }
                let e = "Should get a double here; ixLoop = \(ixLoop), slice = \(slice.toString())"
                print(e)
                fatalError(e)
            }
        }
    }
}

let inputStrand = "L.I(0)L.I(1)N.L.I(2)N.N.I(1)I(1)B(true)D(441.33)D(47.33)D(386.65)"
//let inputStrand = "L.IIXDZ"

//#if true
//let ct = inputStrand.count
//let ix_ = inputStrand.firstIndex(of: D)!
//let st = inputStrand[ix_..<inputStrand.endIndex]
//let ix = st.distance(from: st.startIndex, to: ix_)
//let ff = st.distance(from: ix_, to: st.endIndex)
//
//print(ct, ff)
//
//for loopIx in 1..<ff {
//    print(loopIx, inputStrand[ix_..<inputStrand.index(ix_, offsetBy: loopIx)])
//}
//
//print("fuck", String(inputStrand[ix_..<inputStrand.endIndex]))
//abort()
//#else
//let inputArray = ["L", ".", "I", "I", "X", "D", "Z"]
//let ct = inputArray.count
//let ix = inputArray.firstIndex(of: "D")!
//let ff = ct - ix
//
//print(ct, ff)
//
//for loopIx in 1..<ff {
//    print(loopIx, inputArray[ix..<ix + loopIx])
//}
//
//print("fuck", inputArray[ix..<inputArray.endIndex])
//abort()
//#endif


let tester = TestGetDouble(inputStrand)
tester.testGetDouble()

#if false
func getBool() throws -> Bool {
    print(B)
    _ = boolCursor.advance(2)
    if boolCursor.eodu { try Utilities.hurl(DecodeError.earlyEof); throw DecodeError.fatal }
    
    let firstCharacterIndex = ^boolCursor
    let hereToEnd = boolCursor.input[firstCharacterIndex...]
    
    guard let closeParenIndex = hereToEnd.firstIndex(of: ")")
        else { try Utilities.hurl(DecodeError.inputInconsistent); throw DecodeError.fatal }
    
    let boolSubString = hereToEnd[firstCharacterIndex..<closeParenIndex]
    _ = boolCursor.next()

    guard boolSubString == "true" || boolSubString == "false"
        else { print("barf4", boolSubString); try Utilities.hurl(DecodeError.inputInconsistent); throw DecodeError.fatal }
    
    return boolSubString == "true"
}

func getInt(_ startIndex: String.Index, _ endIndex: String.Index) throws -> Int {
    print(I)
    if intCursor.eodu { try Utilities.hurl(DecodeError.overshot); throw DecodeError.recoverable }
    _ = intCursor.advance(2)

    let firstDigitIndex = ^intCursor
    let hereToEnd = intCursor.input[firstDigitIndex...]
    
    guard let closeParenIndex = hereToEnd.firstIndex(of: ")")
        else { try Utilities.hurl(DecodeError.inputInconsistent); throw DecodeError.fatal }
    
    let intSubString = hereToEnd[firstDigitIndex..<closeParenIndex]
    _ = intCursor.next()

    if let result = Int(intSubString) { print("result = \(result)"); return result }
    else { try Utilities.hurl(DecodeError.inputInconsistent); throw DecodeError.fatal }
}

func getNeuron(_ neuronStartIndex: String.Index, _ neuronEndIndex: String.Index) throws -> Neuron {
    /*

     let layerSegment = originalStrand[layerStartIndex..<layerEndIndex]
     let endOfLayerControlSegment = (^neuronCursor >= layerEndIndex) ? layerEndIndex : ^neuronCursor
     
     let neuronCount = try getInt(layerEndIndex, endOfLayerControlSegment)
     var neuronStartIndex = originalStrand.index(endOfLayerControlSegment, offsetBy: 1)
     
     var neurons = [Neuron]()
     
     for _ in 0..<neuronCount {
     let neuronMeatSegment_ = originalStrand[neuronStartIndex...]
     var neuronEndIndex: String.Index
     
     if let e = neuronMeatSegment_.firstIndex(of: N) { neuronEndIndex = e }
     else { neuronEndIndex = originalStrand.endIndex }
     
     let neuron = try getNeuron(neuronStartIndex, neuronEndIndex)
     neurons.append(neuron)
     
     neuronStartIndex = neuronEndIndex
     }
     
     _ = layerCursor.next()
     
     return Layer(neurons: neurons)
 */
    print(N)

    let neuronSegment = originalStrand[neuronStartIndex..<neuronEndIndex]
    let endOfNeuronControlSegment = (^neuronCursor >= neuronEndIndex) ? neuronEndIndex : ^neuronCursor

    

    _ = neuronCursor.next() // Move to the next neuron gene

    let numberOfActivators = try getInt()
    let numberOfWeights = try getInt()
    
    var activators = [Bool]();   for _ in 0..<numberOfActivators { activators.append(try getBool()) }
    var weights =    [Double](); for _ in 0..<numberOfWeights    { weights.append(try getDouble()) }
    
    let bias = try getDouble()
    let threshold = try getDouble()
    
    return Neuron(activators: activators, weights: weights, bias: bias, threshold: threshold)
}

func getLayer(_ layerStartIndex: String.Index, _ layerEndIndex: String.Index) throws -> Layer {
    print(L)

    let layerSegment = originalStrand[layerStartIndex..<layerEndIndex]
    var endOfLayerControlSegment = originalStrand.endIndex
        
    if let e = layerSegment.firstIndex(where: { $0 == N }) {
        endOfLayerControlSegment = e
    } else {
        try Utilities.hurl(DecodeError.earlyEndOfDecodeUnit); throw DecodeError.recoverable
    }
    
    let neuronCount = try getInt(layerStartIndex, endOfLayerControlSegment)
    var neuronStartIndex = originalStrand.index(endOfLayerControlSegment, offsetBy: 1)
    
    var neurons = [Neuron]()

    for _ in 0..<neuronCount {
        let neuronMeatSegment_ = originalStrand[neuronStartIndex...]
        var neuronEndIndex: String.Index
        
        if let e = neuronMeatSegment_.firstIndex(of: N) { neuronEndIndex = e }
        else { neuronEndIndex = originalStrand.endIndex }

        let neuron = try getNeuron(neuronStartIndex, neuronEndIndex)
        neurons.append(neuron)
        
        neuronStartIndex = neuronEndIndex
    }

    _ = layerCursor.next()
    
    return Layer(neurons: neurons)
}

do {
    var brain: Brain!

    var layers = [Layer]()
    var layerStartIndex = originalStrand.startIndex

    print("R")
    while *layerCursor != nil {
        let layerEndIndex = ^layerCursor
        let layer = try getLayer(layerStartIndex, layerEndIndex)
        layers.append(layer)
        print("\(layers.count) layers so far")
        layerStartIndex = layerEndIndex
    }

    brain = Brain(layers: layers)

    print(brain)
} catch {
    print(error)
}
#endif
