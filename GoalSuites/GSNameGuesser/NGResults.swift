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

class NGResults: GSResults {
    private var expectedOutputEncoded: UInt64 = 0

    private let zName: String
    private let zNameCount: UInt64
    private let zero: UInt64 = 0
    private let exxEff: UInt64 = 0x0F

    public override var lightLabel: String {
        return ", guess: \"\(decodeGuess())\""
    }

    init(nameToGuess: String) {
        self.zName = nameToGuess; self.zNameCount = UInt64(nameToGuess.count)
        super.init()
    }

    private func decodeGuess() -> String {
        var guess: UInt64 = 0

        if actualOutput == Double.nan || actualOutput == Double.infinity ||
            actualOutput == -Double.infinity || actualOutput < 0 {
            guess = 0
        } else {
            guess = UInt64(ceil(actualOutput))
        }

        var decoded = String()
        var workingCopy = guess

        for _ in zero..<zNameCount {
            let ibs = Int(workingCopy & exxEff) % zName.count
            let indexToBitString = zName.index(zName.startIndex, offsetBy: ibs)
            workingCopy >>= 4

            decoded.insert(Character(String(zName[indexToBitString...indexToBitString])), at: decoded.startIndex)
        }

        return decoded
    }

    public override func setTestResults(_ score: Double, _ expectedOutput: Double, _ actualOutput: Double) {
        expectedOutputEncoded = UInt64(expectedOutput)
        super.setTestResults(score, expectedOutput, actualOutput)
    }

}
#if false
private class Scorer {
    let guess: UInt64
    var expectedOutputEncoded: UInt64 = 0
    //    let zName = "Zoe Bishop"
    let zName = "Christian H"
    let zNameCount: UInt64
    let zero: UInt64 = 0

    init(outputs: [Double?]) {
        zNameCount = UInt64(zName.count)
        for vc: UInt64 in zero..<zNameCount { expectedOutputEncoded <<= 4; expectedOutputEncoded |= vc }

        let guess: Double = outputs.compactMap({$0}).reduce(0.0, +)
        if guess == Double.nan || guess == Double.infinity || guess == -Double.infinity || guess < 0 {
            self.guess = 0
        } else {
            self.guess = UInt64(ceil(guess))
        }
    }

    func calculateScore() -> (Double, String) {
        //        let s = String(format: "0x%qX", expectedOutputEncoded)
        //        print(s)

        var decoded = String()
        var workingCopy = expectedOutputEncoded

        workingCopy = guess
        decoded.removeAll(keepingCapacity: true)
        for _ in zero..<zNameCount {
            let ibs = Int(workingCopy & UInt64(0x0F)) % zName.count
            let indexToBitString = zName.index(zName.startIndex, offsetBy: ibs)
            workingCopy >>= 4

            decoded.insert(Character(String(zName[indexToBitString...indexToBitString])), at: decoded.startIndex)
        }

        //        let t = String(format: "0x%qX", guess)
        //        print(t, decoded)

        let finalScore = abs(Double(guess) - Double(expectedOutputEncoded))  // Try for -27.5
        return (finalScore, decoded)
    }
}
#endif
