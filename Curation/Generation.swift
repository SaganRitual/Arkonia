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

class Generation {
    var bestTestSubject: TSHandle?
    var testSubjects: [TSHandle]
    let tsRelay: TSRelay
    var entryTime = TimeInterval(0.0)
    var selectionStatus = SelectionStatus.running
    var ssNextSubject: Int?

    init(_ tsRelay: TSRelay, testSubjects: TSTestGroup) {
        self.tsRelay = tsRelay
        self.testSubjects = Array(testSubjects.testSubjects.keys)
    }
    
    func addTestSubject(_ tsHandle: TSHandle) {
        testSubjects.append(tsHandle)
    }
    
    private func administerTest(to subject: TSHandle, for inputs: [Double]) -> Double? {
        let outputsFromSubject =
            tsRelay.administerTest(to: subject, for: inputs)
        
        if outputsFromSubject == nil { return nil }
        
        guard let fitnessScore = tsRelay.getFitnessScore(for: subject) else { return nil }

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

    private func select(for inputs: [Double], referenceTime: UInt64) -> CuratorStatus {
        var ss = 0
        if let startFrom = self.ssNextSubject { ss = startFrom }
        
        for ix in ss..<self.testSubjects.count {

            if timeToYield(referenceTime: referenceTime) {
                self.ssNextSubject = ix
                return .paused
            }
            
            let _ = self.administerTest(to: testSubjects[ix], for: inputs)
        }
        
        print("G.select -> results", to: &Log.L)
        self.ssNextSubject = nil // This generation is finished; ready for a new one
        return .results(self.bestTestSubject)
    }

    func submitToTest(with sensoryInput: [Double], referenceTime: UInt64) -> CuratorStatus {
        return select(for: sensoryInput, referenceTime: referenceTime)
    }
    
    func timeToYield(referenceTime: UInt64) -> Bool {
        let diff = DispatchTime.now().uptimeNanoseconds - referenceTime
        return diff > UInt64(1e6 * 15)  // 16ms keeps pushing us over the limit
    }
}
