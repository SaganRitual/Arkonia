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

class Selector {
    var bestTestSubject: TSHandle?
    var fullDetails: TSTestSubject?
    var generations = [Generation]()
    var testInputs = [Double]()
    var generationCounter = 0
    var tsRelay: TSRelay
    var testGroup: TSTestGroup
    
    init(_ tsRelay: TSRelay, testGroup: TSTestGroup) { self.tsRelay = tsRelay; self.testGroup = testGroup }
    
    private func administerTest(to generation: Generation, for inputs: [Double]) -> TSHandle? {
        guard let bestSubjectOfGeneration = generation.submitToTest(with: inputs) else { return nil }
        
        if self.bestTestSubject == nil {
            self.bestTestSubject = bestSubjectOfGeneration
            self.fullDetails = testGroup.testSubjects[bestSubjectOfGeneration]
            return self.bestTestSubject
        }
        
        guard let fullDetailsOfMyBest = self.fullDetails else {
            preconditionFailure("Best test subject is set, but no full details")
        }
        
        guard let hisScore = tsRelay.getFitnessScore(for: bestSubjectOfGeneration) else {
            preconditionFailure("Shouldn't get a winner with a nil score")
        }
        
        guard let myScore = fullDetailsOfMyBest.getFitnessScore() else {
            preconditionFailure("Our best test subject has lost his score")
        }
        
        if hisScore < myScore {
            self.bestTestSubject = bestSubjectOfGeneration
            self.fullDetails = testGroup.testSubjects[bestSubjectOfGeneration]
            return self.bestTestSubject
        }
        
        return nil
    }
    
    func select(from generation: Generation, for inputs: [Double]) -> TSHandle? {
        return administerTest(to: generation, for: inputs)
    }
}
