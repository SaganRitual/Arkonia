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
    let testInputSets = [
        [0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09],
        [0.11, 0.12, 0.13, 0.14, 0.15, 0.16, 0.17, 0.18, 0.19],
        [0.21, 0.22, 0.23, 0.24, 0.25, 0.26, 0.27, 0.28, 0.29],
        [0.31, 0.32, 0.33, 0.34, 0.35, 0.36, 0.37, 0.38, 0.39],
        [0.41, 0.42, 0.43, 0.44, 0.45, 0.46, 0.47, 0.48, 0.49]
    ]

    let expectedOutputs: [Double]
    var outputsFromAllPasses = [Double]()
    var kNet: KNet?
    var rawOutputs = [Double?]()

    var suite: GSGoalSuite?

    var lightLabel: String {
        return ": not sure yet"
    }

    var description: String { return "AATester; Arkon goal: add two numbers" }

    init() {
        let cInputs = ArkonCentralDark.selectionControls.cSenseNeurons
        expectedOutputs = testInputSets.map {
            2 * $0.prefix(upTo: cInputs).reduce(0.0, +)
        }
    }

    func postInit(suite: GSGoalSuite) { self.suite = suite }

    func administerTest(to gs: GSSubject) -> Double? {
        gs.fitnessScore = 0.0

        let signalDriver = KSignalDriver(idNumber: gs.fishNumber, fNet: gs.fNet!)
        gs.kNet = signalDriver.kNet

        for (ss, inputSet) in testInputSets.enumerated() {
            let arkonSurvived = signalDriver.drive(sensoryInputs: inputSet)
            if !arkonSurvived { return nil }

            let singlePassOutputs = signalDriver.motorLayer.neurons.compactMap({ $0.relay?.output })
            let thisPassOutput = singlePassOutputs.reduce(0.0, +)
            outputsFromAllPasses.append(thisPassOutput)

            let error = abs(1.0 - (thisPassOutput / expectedOutputs[ss]))
            gs.fitnessScore += error

//            print(
//                ".gsf", gs.fishNumber, error, outputsFromAllPasses[ss], expectedOutputs[ss],
//                (outputsFromAllPasses[ss] / expectedOutputs[ss])
//            )
        }
//        print("gsf", gs.fishNumber, gs.fitnessScore)

        return gs.fitnessScore
    }
}
