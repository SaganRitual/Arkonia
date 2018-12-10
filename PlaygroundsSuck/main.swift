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

let zName = String("Zoe Bishop")

extension Character {
    var asciiValue: Int {
        get {
            let s = String(self).unicodeScalars
            return Int(s[s.startIndex].value)
        }
    }
}

var huffZoe: UInt64 = 0
var zNameCount = UInt64(zName.count)
var zero: UInt64 = 0
for vc: UInt64 in zero..<zNameCount {
    huffZoe <<= 4
    huffZoe |= vc
}

let s = String(format: "0x%qX", huffZoe)
print(s)

var decoded = String()
var workingCopy = huffZoe
let ten = UInt64(10)
let four = UInt64(4)
for guess in (huffZoe - ten)..<(huffZoe + ten) {
    workingCopy = guess
    decoded.removeAll(keepingCapacity: true)
    for _ in zero..<zNameCount {
        let ibs = Int(workingCopy & UInt64(0x0F)) % zName.count
        let indexToBitString = zName.index(zName.startIndex, offsetBy: ibs)
        workingCopy >>= 4

        decoded.insert(Character(String(zName[indexToBitString...indexToBitString])), at: decoded.startIndex)
    }

    let s = String(format: "0x%qX", guess)
    print(decoded, s)
}
