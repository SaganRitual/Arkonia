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

final class AATester: GSTester {
//    let testInputSets = [
//        [1.0, 1.0], [10.0, 10.0], [100.0, 100.0], [1000.0, 1000.0],
//        [5.0, 995.0], [47.0, 357.0], [756.0, 22.0], [1111.0, 1066.0]
//    ]

    let testInputSets = [ [5.0, 7.0], [12.0, 13.0] ]

    var expectedOutput = 0.0
    var reducedInput = [0.0, 0.0]

    var rawOutputs = [Double?]()
    var reducedOutput = 0.0

    var suite: GSGoalSuite?

    var lightLabel: String {
        return "\(reducedInput[0]) + \(reducedInput[1]) ?= \(reducedOutput.sTruncate(1))" }

    var description: String { return "AATester; Arkon goal: add two numbers" }

    init() {
        for set in testInputSets { reducedInput[0] += set[0]; reducedInput[1] += set[1] }

        expectedOutput = testInputSets.map { $0[0] - $0[1] }.reduce(0.0, +)
    }

    func postInit(suite: GSGoalSuite) { self.suite = suite }

    func administerTest(to gs: GSSubject) -> Double? {
        for inputSet in testInputSets {
            rawOutputs = gs.brain.stimulate(sensoryInputs: inputSet)
            reducedOutput = rawOutputs.compactMap({$0}).reduce(0.0, +)
        }

//        print("well? \(reducedOutput) - \(expectedOutput)")
        gs.fitnessScore = abs(reducedOutput - expectedOutput) / Double(testInputSets.count)

        return gs.fitnessScore
    }
}
