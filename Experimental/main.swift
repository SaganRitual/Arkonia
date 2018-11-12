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
