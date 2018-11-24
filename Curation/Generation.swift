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

typealias FitnessTestFunction = ([Double]) -> Double?
typealias TestSubjectFactoryFunction = (_ genome: Genome, _ mutate: Bool) -> TSTestSubject

class Generation {
    var bestTestSubject: TSHandle?
    var testSubjects = [TSHandle]()
    var testSubjectFactory: TestSubjectFactory?
    var testSubjectScoringFunction: FitnessTestFunction?
    let tsRelay: TSRelay
    
    init(_ tsRelay: TSRelay) { self.tsRelay = tsRelay }
    
    func addTestSubject(_ tsHandle: TSHandle) {
    }
    
    private func administerTest(to subject: TSHandle, for inputs: [Double]) -> Double? {
        guard let outputsFromSubject =
            tsRelay.administerTest(to: subject, for: inputs) else { return nil }
        
        guard let scorer = testSubjectScoringFunction else {
            preconditionFailure("Can't score without a scoring function")
        }
        
        guard let fitnessScore = scorer(outputsFromSubject) else { return nil }

        guard let bestTestSubject = self.bestTestSubject else {
            self.bestTestSubject = subject
            return fitnessScore
        }
        
        guard let bestScore = tsRelay.getFitnessScore(for: bestTestSubject) else {
            preconditionFailure("Shouldn't have a best subject without a score")
        }
        
        if fitnessScore < bestScore { self.bestTestSubject = subject }
        
        return fitnessScore
    }
    
    func setFitnessTester(_ tester: @escaping FitnessTestFunction) {
        self.testSubjectScoringFunction = tester
    }

    
    func setTestSubjectFactory(_ factory: TestSubjectFactory) {
        testSubjectFactory = factory
    }

    private func select(for inputs: [Double]) -> TSHandle? {
        for testSubject in testSubjects {
            let _ = self.administerTest(to: testSubject, for: inputs)
        }
        
        return self.bestTestSubject
    }
    
    func submitToTest(with sensoryInput: [Double]) -> TSHandle? {
        return select(for: sensoryInput)
    }
}
