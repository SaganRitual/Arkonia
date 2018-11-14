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
    
    func decode() {
        
    }
}

extension StrandDecoder {
    static func parse<PrimitiveType>(_ slice: StrandSlice) -> PrimitiveType? {
        fatalError("Should never come here")
    }
    
    static func parseBool(_ slice: StrandSlice) -> Bool? {
        let truthy = "true", falsy = "false", stringy = String(slice)
        switch stringy {
        case truthy: return true
        case falsy:  return false
        default:     return nil
        }
    }
    
    static func parseDouble(_ slice: StrandSlice) -> Double? {
        let s = String(slice)
        guard let d = Double(s) else { return nil }

        let n = NSNumber(floatLiteral: d)
        return Double(truncating: n)
    }
    
    static func parseInt(_ slice: StrandSlice) -> Int? { return Int(slice) }
}
