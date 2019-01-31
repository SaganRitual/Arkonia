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

final class AATester: GSTesterProtocol {
//    let testInputSets = [
//        [1.0, 1.0], [10.0, 10.0], [100.0, 100.0], [1000.0, 1000.0],
//        [5.0, 995.0], [47.0, 357.0], [756.0, 22.0], [1111.0, 1066.0]
//    ]

    let testInputSets = [ [5.0, 1.0, 7.0, 1.0, 11.0] ]
    let expectedOutputs = [23.0]
    var cookedOutputs = [Double]()
    var kNet: KNet?
    var rawOutputs = [Double?]()

    var suite: GSGoalSuite?

    var lightLabel: String {
        return ": not sure yet"
    }

    var description: String { return "AATester; Arkon goal: add two numbers" }

    func postInit(suite: GSGoalSuite) { self.suite = suite }

    func administerTest(to gs: GSSubject) -> Double? {
        gs.fitnessScore = 0.0

        let kDriver = KDriver(fNet: gs.fNet!)
        gs.kNet = kDriver.kNet

        for (ss, _/*inputSet*/) in testInputSets.enumerated() {
            kDriver.drive(sensoryInputs: testInputSets[0])

            let nonils = rawOutputs.compactMap({$0})
            if nonils.isEmpty { return nil }

            let result = nonils.reduce(0.0, +)
            cookedOutputs.append(result)

            let error = abs(1.0 - (cookedOutputs[ss] / expectedOutputs[ss]))
            gs.fitnessScore += error

//            print(".gsf", gs.fishNumber, error, cookedOutputs[ss], expectedOutputs[ss], (cookedOutputs[ss] / expectedOutputs[ss]))
        }
//        print("gsf", gs.fishNumber, gs.fitnessScore)

        return gs.fitnessScore
    }
}
