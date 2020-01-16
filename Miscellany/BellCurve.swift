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
import GameKit

// With deepest gratitude to Stack Overflow dude
// https://stackoverflow.com/users/2538939/code-different
// https://stackoverflow.com/a/44535176/1610473

class BellCurve_ {
    static let randomSource = GKARC4RandomSource()
    static var randomDistribution = GKGaussianDistribution(randomSource: randomSource, mean: 0.0, deviation: 3)

    static func getRandom() -> Double {
        let u = randomDistribution.nextUniform()
        let du = Double(u)
        return du
    }
}

// With deepest gratitude to Stack Overflow dude
// https://stackoverflow.com/users/2538939/code-different
// https://stackoverflow.com/a/49471411/1610473
class BellCurve {
    static private let randomSource = GKARC4RandomSource()

    func nextFloat() -> Float {
        let mean: Float = 0.0, deviation: Float = 2.0
        let x1 = BellCurve.randomSource.nextUniform() // a random number between 0 and 1
        let x2 = BellCurve.randomSource.nextUniform() // a random number between 0 and 1
        let z1 = sqrt(-2 * log(x1)) * cos(2 * Float.pi * x2) // z1 is normally distributed

        // Convert z1 from the Standard Normal Distribution to our Normal Distribution
        // Note that the conversion will give us a range of -10..<10. I still want -1..<1
//        Debug.log((z1 * deviation + mean).sTruncate())
        return (z1 * deviation + mean) / 10.0
    }
}
