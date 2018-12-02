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

class Stack {
    private var currentBest: TSTestSubject? // Not on the stack
    private var eqTest = Curator.EQTest.ge
    private var theStack = TSArray()

    private var newArrivals = TSArray()
    private var maxEQScores = selectionControls.stackNoobsLimit

    public func pop() -> TSTestSubject { return theStack.pop() }
    public func push(_ ts: TSTestSubject) { theStack.push(ts) }
    public func popBack() { theStack.popBack() }

    func beatScore(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        return lhs.fitnessScore! < rhs.fitnessScore!
    }

    public func getSelectionParameters() -> TSTestSubject {
        guard let cb = currentBest else { fatalError() }
        return cb
    }

    func matchScore(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        return lhs.fitnessScore! == rhs.fitnessScore!
    }
    
    func postInit(aboriginal: TSTestSubject) {
        currentBest = aboriginal
    }
    
    func sortAscending(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        return lhs.fitnessScore! < rhs.fitnessScore!
    }
    
    func sortDescending(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        return lhs.fitnessScore! > rhs.fitnessScore!
    }

    func preprocessNewArrivals(_ newArrivals: TSArray) -> TSArray {
        return Array(newArrivals).sorted { sortDescending($0, $1) }
    }
    
    func stack(_ na: TSArray) {
        if let cb = currentBest {
            theStack.push(cb)
//            print("Stack.pushCB( \(cb): \(cb.fitnessScore!))")
        }
        currentBest = nil
        
        let newArrivals = preprocessNewArrivals(na)
        
        // preprocess sorts in descending order, so we'll get the matchers
        // first, if there are any.
        var eqTester = matchScore
        for newArrival in newArrivals {
            let ctMatchingScore = theStack.filter { eqTester($0, newArrival) }.count
            guard ctMatchingScore < selectionControls.stackNoobsLimit else { continue }

            eqTester = beatScore

            // We come here if we're still under the limit for
            // matching scores, or if we're processing test subjects
            // that have better scores
//            print("Stack.push( \(newArrival.fishNumber): \(newArrival.fitnessScore!))")
            theStack.push(newArrival)
        }
        
        if let bestOfNew = newArrivals.last {
            let ctBeatingScore = theStack.filter { beatScore($0, bestOfNew) }.count

            eqTest = ctBeatingScore >= selectionControls.stackNoobsLimit ? .gt : .ge
            theStack.popBack()
        }
        
        currentBest = theStack.pop()
//        print("Stack.pop() -> \(currentBest!.fishNumber) : \(currentBest!.fitnessScore!)")
    }
}
