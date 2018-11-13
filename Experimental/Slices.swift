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

fileprivate var B: Character { return Utilities.B[Utilities.B.startIndex] }
fileprivate var D: Character { return Utilities.D[Utilities.D.startIndex] }
fileprivate var I: Character { return Utilities.I[Utilities.I.startIndex] }
fileprivate var L: Character { return Utilities.L[Utilities.L.startIndex] }
fileprivate var N: Character { return Utilities.N[Utilities.N.startIndex] }
fileprivate var b: Character { return Utilities.b[Utilities.b.startIndex] }
fileprivate var t: Character { return Utilities.t[Utilities.t.startIndex] }

let originalStrands = StrandBuilder.buildBrainStrands(howMany: 1)
let originalStrand = originalStrands[0]

print(originalStrand)

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

func getValue(from iterator: StrandIterator) throws -> String {
    let cursorLimit = getCursorLimit()
    
    print("VV", ^^iterator, cursorLimit)
    
    let previousIndex = ^iterator
    let scanner = iterator
    
    _ = scanner.advance(2)
    if scanner.eof { try Utilities.hurl(DecodeError.earlyEof); throw DecodeError.fatal }
    
    let firstTokenIndex = ^scanner == scanner.input.endIndex ? previousIndex : ^scanner
    let hereToEnd = iterator.input[firstTokenIndex...]
    
    guard let closeParenIndex = hereToEnd.firstIndex(of: ")")
        else { try Utilities.hurl(DecodeError.inputInconsistent); throw DecodeError.fatal }
    
    let substring = hereToEnd[firstTokenIndex..<closeParenIndex]
    _ = iterator.next()
    
    return String(substring)
}

func getCursorLimit() -> String.IndexDistance {
    return (^layerCursor < ^neuronCursor) ? ^^layerCursor : ^^neuronCursor
}

func getDouble() throws -> Double {
    print(D)
    
    var doubleSubstring: Substring?
    do {
        doubleSubstring = try getValue(from: doubleCursor)
    } catch DecodeError.overshot {
        doubleSubstring =
    }
    
    guard let rawDouble = Double(doubleSubString)
        else { try Utilities.hurl(DecodeError.inputInconsistent); throw DecodeError.fatal }
    
    return Double(truncating: NSNumber(floatLiteral: rawDouble))
}

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

enum DecodeError: Error {
    case earlyEndOfDecodeUnit, fatal, general, inputInconsistent, overshot, recoverable
}

func getNeuronControlInt(_ neuronSegment: Substring) throws -> (Int, String.Index)? {
}

func getNeuronDouble(_ neuronSegment: Substring) throws -> Double {
    
}

func getNeuron(_ neuronSegment: Substring) throws -> Neuron {
    print(N)
    
    var nextStop = neuronSegment.endIndex

    var activatorsCount: Int?
    var weightsCount: Int?
    
    var iMeatStart = neuronSegment.startIndex
    var intStart: String.Index?
    var doubleStart: String.Index?
    
    var workingStartIndex = neuronSegment.startIndex
    var workingSegment = neuronSegment[workingStartIndex...]

    if let (a, ix) = try getNeuronControlInt(workingSegment) {
        activatorsCount = a
        workingStartIndex = ix
        workingSegment = neuronSegment[workingStartIndex...]
    }
    
    if let (a, ix) = try getNeuronControlInt(workingSegment) {
        weightsCount = a
        workingStartIndex = ix
        workingSegment = neuronSegment[workingStartIndex...]
    }
    
    var activators = [Bool]()
    
    if let a = activatorsCount {
        for _ in 0..<a {
            if workingSegment[workingStartIndex] == B,
                let ix = workingSegment.index(workingSegment.startIndex, offsetBy: 2, limitedBy: workingSegment.endIndex)
            {
                workingSegment = workingSegment[ix...]
                if let e = workingSegment.firstIndex(where: { $0 == B }) {
                    workingStartIndex = ix
                    workingSegment = workingSegment[ix..<e]
                    var b = try getBool(workingSegment)
                } else {
                    try Utilities.hurl(DecodeError.earlyEndOfDecodeUnit); throw DecodeError.recoverable
                }
            }
        }
    }
    
    var weights = [Double]()
    var bias = 0.0
    var threshold = 0.0
    
    if let w = weightsCount {
        for weightIx in 0..<(w + 2) {
            if workingSegment[workingStartIndex] == D,
                let ix = workingSegment.index(workingSegment.startIndex, offsetBy: 2, limitedBy: workingSegment.endIndex)
            {
                workingSegment = workingSegment[ix...]
                if let e = workingSegment.firstIndex(where: { $0 == D }) {
                    workingStartIndex = ix
                    workingSegment = workingSegment[ix..<e]
                    var d = try getDouble(workingSegment)
                    
                    if weightIx > w {
                        if weightIx > w + 1 {
                            threshold = d
                        } else {
                            bias = d
                        }
                    } else {
                        weights.append(d)
                    }
                } else {
                    try Utilities.hurl(DecodeError.earlyEndOfDecodeUnit); throw DecodeError.recoverable
                }
            }
        }
    }
}

func getLayer(_ layerSegment: Substring) throws -> Layer {
    print(L)
    
    var neurons = [Neuron]()

    var endOfLayerControlSegment = originalStrand.endIndex

    guard let e = layerSegment.firstIndex(where: { $0 == N }) else {
        if neurons.isEmpty {
            try Utilities.hurl(DecodeError.earlyEndOfDecodeUnit)
            throw DecodeError.recoverable
        }
        
        return Layer(neurons: neurons)
    }
    
    endOfLayerControlSegment = e
    
    let layerControlSegment = layerSegment[layerSegment.startIndex..<endOfLayerControlSegment]
    let neuronCount = try getInt(layerControlSegment)
    
    // Skip past the N-marker
    var neuronStartIndex = originalStrand.index(endOfLayerControlSegment, offsetBy: 1)
    var layerMeatSegment_ = originalStrand[neuronStartIndex...]

    var neuronEndIndex = layerSegment.endIndex
    
    for _ in 0..<neuronCount {
        if let e = layerMeatSegment_.firstIndex(where: { $0 == N }) {
            neuronEndIndex = e
        }
        
        let neuronSegment_ = layerMeatSegment_[neuronStartIndex..<neuronEndIndex]
        var neuronEndIndex = neuronSegment_.endIndex
        
        if let e = neuronSegment_.firstIndex(of: N) { neuronEndIndex = e }
        
        let neuronSegment = neuronSegment_[neuronStartIndex..<neuronEndIndex]
        let neuron = try getNeuron(neuronSegment)

        neurons.append(neuron)
        neuronStartIndex = neuronEndIndex
        
        layerMeatSegment_ = layerMeatSegment_[neuronStartIndex...]
    }
    
    _ = layerCursor.next()
    
    return Layer(neurons: neurons)
}

do {
    var brain: Brain!
    
    var layers = [Layer]()
    var layerStartIndex = originalStrand.startIndex
    
    _ = layerCursor.next()  // Move to the next layer indicator
    
    print("R")
    while *layerCursor != nil {
        let layerEndIndex = ^layerCursor
        let layer = try getLayer(originalStrand[layerStartIndex..<layerEndIndex])
        layers.append(layer)
        print("\(layers.count) layers so far")
        layerStartIndex = layerEndIndex
    }
    
    brain = Brain(layers: layers)
    
    print(brain)
} catch {
    print(error)
}
