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

typealias TSHandle = Int

class TSRelay {
    var testSubjects: TSTestGroup
    
    init(_ testSubjects: TSTestGroup) {
        self.testSubjects = testSubjects
    }
    
    func administerTest(to which: TSHandle, for inputs: [Double]) -> ([Double], Double)? {
        guard let ts = testSubjects[which] else
            { preconditionFailure("Can't find subject \(which)") }

        return ts.submitToTest(for: inputs)
    }
    
    func getFitnessScore(for which: TSHandle) -> Double? {
        guard let ts = testSubjects[which] else
        { preconditionFailure("Can't find subject \(which)") }
        
        return ts.getFitnessScore()
    }

    func getFishNumber(for which: TSHandle) -> Int {
        guard let ts = testSubjects[which] else
            { preconditionFailure("Can't find subject \(which)") }

        return ts.myFishNumber
    }
    
    func getGenome(of which: TSHandle) -> Genome {
        guard let ts = testSubjects[which] else
            { preconditionFailure("Can't find subject \(which)") }
        
        return ts.genome
    }
    
    func setBrain(_ brain: BrainStem, for which: TSHandle) {
        guard let ts = testSubjects[which] else
            { preconditionFailure("Can't find subject \(which)") }

        ts.setBrain(brain)
    }
}
