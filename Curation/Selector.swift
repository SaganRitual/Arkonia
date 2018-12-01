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
    public var stud: TSTestSubject?
    private let ctOffspring: Int
    private var tsFactory: TestSubjectFactory
    private var fitnessTester: FTFitnessTester!
    unowned private var dQueue: DispatchQueue
    unowned private var dGroup: DispatchGroup

    init(tsFactory: TestSubjectFactory, dQueue: DispatchQueue, dGroup: DispatchGroup) {
        self.tsFactory = tsFactory
        self.dQueue = dQueue
        self.dGroup = dGroup
        
        self.fitnessTester = tsFactory.makeFitnessTester()
        
        // Do this after creating the fitness tester; the fitness
        // tester is the one that sets the selection controls. Ugly. Fix it.
        self.ctOffspring = selectionControls.howManySubjectsPerGeneration
    }

    func scoreAboriginal(_ aboriginal: TSTestSubject) {
        guard let score = fitnessTester.administerTest(to: aboriginal)
            else { fatalError() }

        aboriginal.fitnessScore = score
    }
    
    func select(eqTest: Curator.EQTest, against stud: TSTestSubject) -> [TSTestSubject]? {
        var results = TSArray()
        dQueue.async(group: dGroup) {
            switch eqTest {
            case .gt: if let r = self.selectBt(against: stud) { results = r }
            case .ge: if let r = self.selectBe(against: stud) { results = r }
            }
        }
        
        dGroup.notify(queue: dQueue) {}
        
        return results
    }

    private func selectBt(against stud: TSTestSubject) -> [TSTestSubject]? {
        guard let ge = select(eqTest: .ge, against: stud) else { return nil }
        
        var stemTheFlood = TSArray()
        
        guard let ssScore = stud.fitnessScore else { fatalError() }

        for gge in ge {
            guard let tsScore = gge.fitnessScore else { fatalError() }
            
            let scoreToBeat = stemTheFlood.isEmpty ? ssScore : stemTheFlood[0].fitnessScore!
            if tsScore >= scoreToBeat { continue }

            stemTheFlood.push(gge)
            
            if stemTheFlood.count >= 5 {
                stemTheFlood.popBack()
            }
        }
        
//        if !stemTheFlood.isEmpty { print("selectBt returns best score \(stemTheFlood[0].fitnessScore!)") }
//        else { print("selectBt returns nil") }
        return stemTheFlood.isEmpty ? nil : stemTheFlood
    }

    private func selectBe(against stud: TSTestSubject) -> [TSTestSubject]? {
//        print("Q", terminator: "")
        var bestScore = stud.fitnessScore
        var btMode = false

        var stemTheFlood = [TSTestSubject]()
        for _ in 0..<ctOffspring {
//            print("R", terminator: "")
            guard let ts = tsFactory.makeTestSubject(parent: stud, mutate: true)
                else { continue }
//            let endIndex = ts.genome.index(ts.genome.startIndex, offsetBy: 40)
//            print("S(\(ts.genome[..<endIndex]))")

            // No point keeping exact copies
            if ts.genome == stud.genome { continue }

//            print("T", terminator: "")
            guard let score = fitnessTester.administerTest(to: ts)
                else { continue }

//            print("U(\(score))", terminator: "")

            ts.fitnessScore = score
            if score > bestScore! { continue }
            if score == bestScore! && btMode { continue }
            
            // This is select .be, so if it's not worse
            // than the target score, we'll take it.
            bestScore = score

            // Set btMode to stop accepting equal scores 
            if stemTheFlood.count >= 5 { btMode = true; stemTheFlood.popBack() }
            stemTheFlood.push(ts)
        }
//        print("Z", terminator: "")

//        if !stemTheFlood.isEmpty { print("selectBe returns best score \(stemTheFlood[0].fitnessScore!)") }
//        else { print("selectBe returns nil") }
        return stemTheFlood.isEmpty ? nil : stemTheFlood
    }
}
