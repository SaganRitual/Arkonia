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

class NGTester: GSTester {
    static private var exxEff: UInt64 = 0x0F
    static private var expectedOutputEncoded: UInt64 = 0x123456789abcdef
    static private var zName: String = "Zoe Bishop"
    static private var zNameCount: UInt64!
    static private var zero: UInt64 = 0

    public override var lightLabel: String { return "not available" }

    static func decodeGuess(_ actualOutput: Double) -> String {
        var guess: UInt64 = 0

        if actualOutput == Double.nan || actualOutput == Double.infinity ||
            actualOutput == -Double.infinity || actualOutput < 0 ||
            actualOutput > Double(UInt64.max) || actualOutput < -Double(UInt64.max) {
            guess = 0
        } else {
            guess = UInt64(ceil(actualOutput))
        }

        var decoded = String()
        var workingCopy = guess
        self.zNameCount = UInt64(zName.count)

        for _ in zero..<zNameCount {
            let ibs = Int(workingCopy & exxEff) % zName.count
            let indexToBitString = zName.index(zName.startIndex, offsetBy: ibs)
            workingCopy >>= 4

            let s = String(zName[indexToBitString...indexToBitString])
            decoded.insert(Character(s), at: decoded.startIndex)
        }

        return decoded
    }

    static func zSetup(nameToGuess: String) {
        zName = nameToGuess; zNameCount = UInt64(nameToGuess.count)

        for vc: UInt64 in zero..<zNameCount { expectedOutputEncoded <<= 4; expectedOutputEncoded |= vc }
    }

}
