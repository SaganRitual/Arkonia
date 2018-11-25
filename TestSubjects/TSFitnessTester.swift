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

class TestSubjectFitnessTester: SelectionFitnessTester {
    func administerTest(to testSubject: TSTestSubject, for sensoryInput: [Double]) -> [Double]? {
        guard let b = testSubject.brain else { preconditionFailure("No brain, no test.") }
        let outputs = b.stimulate(inputs: sensoryInput)
        setFitnessScore(for: testSubject, outputs: outputs)
        return outputs
    }
    
    func getFitnessScore(for testSubject: TSTestSubject) -> Double?
    { return testSubject.getFitnessScore() }
    
    func setFitnessScore(for testSubject: TSTestSubject, outputs: [Double]?) {
        guard let outputs = outputs else { return }
        let totalOutput = outputs.reduce(0, +)
        testSubject.setFitnessScore(abs(totalOutput - 17))    // The number I want the brains to guess
    }
}
