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

protocol GSTesterProtocol: class, LightLabelProtocol {
    func administerTest(to gs: GSSubject) -> Double?
    func postInit(suite: GSGoalSuite)
}

class GSScore: CustomStringConvertible, Hashable {
    var score = 0.0

    public var description: String {
        return score.sTruncate()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(score)
    }

    static func == (_ lhs: GSScore, _ rhs: GSScore) -> Bool { return lhs.score == rhs.score }
}

class GSTester: GSTesterProtocol {
    var actualOutput: Double!
    var decodedGuess: String!
    var expectedOutput: Double
    var inputs: [Double]
//    var outputs: [Double?]
    private weak var suite: GSGoalSuite?

    var lightLabel: String {
        return ", guess: \(actualOutput.sciTruncate(5))"
    }

    init(expectedOutput: Double) {
        let inputsCount = ArkonCentralDark.selectionControls.cSenseNeurons
//        let outputsCount = ArkonCentralDark.selectionControls.cMotorNeurons

        inputs = Array(repeating: 1.0, count: inputsCount)

        self.expectedOutput = expectedOutput
    }

    func postInit(suite: GSGoalSuite) {
        self.suite = suite
    }

    func administerTest(to gs: GSSubject) -> Double? {
        gs.fitnessScore = 0.0

        let kDriver = KDriver(fNet: gs.fNet!, idNumber: gs.fishNumber)
        gs.kNet = kDriver.kNet
        kDriver.drive(sensoryInputs: inputs)

        let nonils = kDriver.motorOutputs.compactMap({$0})
        if nonils.isEmpty { return nil }

        let result = nonils.reduce(0.0, +)
        gs.fitnessScore = abs(result - expectedOutput)

        decodedGuess = NGTester.decodeGuess(result * 1e14)

        return gs.fitnessScore
    }
}
