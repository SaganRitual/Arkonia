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

import Dispatch
import Foundation
import GameKit

#if EXPERIMENTAL
print("Experimental")
#endif

#if RUN_DARK
print("Run dark")
#endif

enum ArkonGoal {
    case guessNumber(theNumber: Double)
}

struct Chucker {
    let goalSuite: GSGoalSuite

    init(_ goal: ArkonGoal) {
        switch goal {
        case let .guessNumber(theNumber):
            goalSuite = GSGoalSuite(guess: theNumber)
        }
    }

    func run() -> GSSubject? { return goalSuite.run() }
}

let chucker = Chucker(.guessNumber(theNumber: 42.4242))
if let winner = chucker.run() {
    print(winner)
} else {
    print("No winner--they all died, and you're a bad person.")
}
