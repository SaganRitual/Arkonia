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

protocol ValueSliceProtcol {
    associatedtype WrapperType: DoNada
    associatedtype HelperType
    
    init(_ inputSlice: StrandSlice)
    func getResult() -> (WrapperType.PrimitiveType, StrandIndex)?
}

protocol DoNada {
    associatedtype PrimitiveType
    func getResult() -> PrimitiveType?
}

class GeneWrapper<PrimitiveType>: DoNada {
    func getResult() -> PrimitiveType? { return nil }
}

class BoolWrapper: GeneWrapper<Bool> {
    var theBool: Bool?
    override func getResult() -> Bool? { return theBool }
}

class IntWrapper: GeneWrapper<Int> {
    var theInt: Int?
    override func getResult() -> Int? { return theInt }
}

class DoubleWrapper: GeneWrapper<Double> {
    var theDouble: Double?
    override func getResult() -> Double? { return theDouble }
}

class GeneHelper<WrapperType: GeneWrapper<Any>>: ValueSliceProtcol {
    typealias HelperType = GeneHelper
    
    let slice: StrandSlice
    required init(_ slice: StrandSlice) { self.slice = slice }
    
    func getGeneWrapper(_ valueSlice: StrandSlice) -> WrapperType {
        return WrapperType(valueSlice)
    }
    
    func getResult(_ sliceWithGeneMarker: StrandSlice) -> (WrapperType.Type, StrandIndex)? {
        var valueSlice = slice.dropFirst(2)    // Skip the gene marker and the paren
        
        // Not fatal, it just means there's no double where we
        // expected one. The neuron may be salvageable. There
        // must be at least two characters available: at least
        // one digit, and the closing paren.
        guard valueSlice.count >= 2 else { return nil }
        
        var ixOfCloseParen = valueSlice.endIndex
        if let ix = valueSlice.firstIndex(where: { $0 == ")" }) {
            ixOfCloseParen = ix
        }
        
        //        let ixOfNextSymbol = (ixOfCloseParen < valueSlice.endIndex) ?
        //            valueSlice.addIx(ixOfCloseParen, 1) : ixOfCloseParen
        let ixOfNextSymbol = valueSlice.startIndex
        
        valueSlice = valueSlice[..<ixOfCloseParen]
        
        let geneWrapper = getGeneWrapper(valueSlice)
        if let result = geneWrapper.getResult() {
            return (result, ixOfNextSymbol)
        }
        
        return nil
    }
}

class BoolGeneHelper: GeneHelper<BoolWrapper> {
    typealias HelperType = BoolGeneHelper
}

class IntGeneHelper: GeneHelper<IntWrapper> {
    typealias HelperType = IntGeneHelper
}
class DoubleGeneHelper: GeneHelper<DoubleWrapper> {
    typealias HelperType = DoubleGeneHelper
}

class StrandDecoder {
    let inputStrand: Strand
    
    init(_ inputStrand: Strand) {
        self.inputStrand = inputStrand
    }
    
    func decode() {
        
    }
}
