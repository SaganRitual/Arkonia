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

protocol GSTesterProtocol: class, CustomStringConvertible {
    var inputs: [Double] { get }

    func administerTest(to gs: GSSubject) -> Double?
}

class GSTester: GSTesterProtocol {
    var inputs: [Double]
    var outputs: [Double?]
    var theNumber: Double

    var description: String {
        return "GSTester; Arkon goal: guess the number \(theNumber) -- generating neutral inputs for test." }

    required init(guess theNumber: Double) {
        let inputsCount = GSGoalSuite.selectionControls.howManySenses
        let outputsCount = GSGoalSuite.selectionControls.howManyMotorNeurons

        inputs = Array(repeating: 1.0, count: inputsCount)
        outputs = Array(repeating: nil, count: outputsCount)
        self.theNumber = theNumber

        print(self)
    }

    func administerTest(to gs: GSSubject) -> Double? {
        precondition(!inputs.isEmpty, "No input available")

        outputs = gs.brain.stimulate(sensoryInputs: inputs)

        let guess = outputs.compactMap({$0}).reduce(0.0, +)
        gs.results.fitnessScore = abs(guess - self.theNumber)

        return gs.results.fitnessScore
    }
}
