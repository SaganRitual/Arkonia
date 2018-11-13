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
