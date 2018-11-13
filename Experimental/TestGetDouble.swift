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

func makeSlice(_ string: String, _ startIndex: Int, _ endIndex: Int) -> StrandSlice {
    let rangeStart = string.index(string.startIndex, offsetBy: startIndex)
    let rangeEnd = string.index(string.startIndex, offsetBy: endIndex)
    return string[rangeStart..<rangeEnd]
}

func makeSlice(_ string: String, _ startIndex: StrandIndex, _ rangeEnd: Int) -> StrandSlice {
    let endIndex = string.index(startIndex, offsetBy: rangeEnd)
    return string[startIndex..<endIndex]
}

func makeSlice(_ slice: StrandSlice, _ startIndex: StrandIndex, _ rangeEnd: Int) -> StrandSlice {
    let endIndex = slice.index(startIndex, offsetBy: rangeEnd)
    return slice[startIndex..<endIndex]
}

class TestGetDouble {
    let inputStrand = "L.I(0)L.I(1)N.L.I(2)N.N.I(1)I(1)B(true)D(441.33)D(47.33)D(386.65)"

    func hardTestGetDouble() {
        let input = "DDDLLLLLLLL"
        if let (theDouble, nextIndex) = StrandDecoder(input).getDouble(input[...]) {
            Utilities.clobbered("Should not have succeeded getting a double; double = \(theDouble); nextIndex = \(nextIndex)")
            return
        }
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
