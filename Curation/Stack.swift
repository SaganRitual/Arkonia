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
    // These two are strong references. The Curator will forget about
    // them when it's not testing them.
    private var highWaterHolder: TSTestSubject?
    private var currentBenchmarkHolder: TSTestSubject? // Not on the stack
    private var currentBestScore = Double.infinity

    private var theStack = TSArray()

    private var maxEQScores = selectionControls.stackTieScoresLimit
    private var retreatLock: Double?

    public var count: Int { return theStack.count }

    public func pop() -> TSTestSubject { let f = theStack.pop(); return f }
    public func push(_ ts: TSTestSubject) { theStack.push(ts) }
    public func popBack() { _ = theStack.popBack() }

    private var retreatNeeded = false
    
    private var candidateFilterType = CandidateFilter.be
    
    public func getSelectionParameters() -> (TSTestSubject, CandidateFilter) {
        guard let cb = currentBenchmarkHolder else { fatalError() }
        let cf = self.candidateFilterType
        return (cb, cf)
    }

    public func postInit(aboriginal: TSTestSubject) {
        currentBenchmarkHolder = aboriginal
        highWaterHolder = aboriginal
    }

    public func stack(_ na: TSArray) {
        let debugCBH = currentBenchmarkHolder
        let debugCBS = currentBestScore

        currentBestScore = Double.infinity
        
        if let cb = currentBenchmarkHolder {
            theStack.push(cb)
            currentBestScore = cb.fitnessScore!
            if currentBestScore < highWaterHolder!.fitnessScore! {
                highWaterHolder = cb
            }
//            print("Stack.pushCB(\(cb))")
        }
        
        currentBenchmarkHolder = nil

        // preprocess sorts in descending order, so we'll get the matchers
        // first, if there are any.
        let newArrivals =
            Array(na).sorted { sortDescending($0, $1) }

        keepKeepers(newArrivals)

        currentBenchmarkHolder = theStack.pop()
        currentBestScore = currentBenchmarkHolder!.fitnessScore!

        updateRetreatStatus(debugCBH, debugCBS)
    }
}

private extension Stack {
    
    func keepKeepers(_ newArrivals: TSArray) {
        
        retreatNeeded = true
        var miniStack = [TSTestSubject]()
        
        candidateFilterType = .be
        for newArrival in newArrivals where canAcceptCandidate(newArrival) {
            guard let score = newArrival.fitnessScore else { preconditionFailure() }
            if let rL = retreatLock, score >= rL { _ = theStack.pop(); continue }
            
            // We're full up on people matching the current
            // score; ignore everyone until we get one that
            // beats it.
            candidateFilterType = .bt
            retreatNeeded = false
            retreatLock = nil
            
            let ctMatchingScore = theStack.filter {
                candidateFilter($0, newArrival)
                }.count
            
            guard ctMatchingScore < maxEQScores else { continue }
            
            // We come here if we're still under the limit for
            // matching scores, or if we're processing test subjects
            // that have better scores
            //            print("Stack.push( \(newArrival.fishNumber): \(newArrival.fitnessScore!))")
            //            print("f(\(newArrival.fishNumber)), V(\(newArrival.brain.allLayersConnected)) ", terminator: "")

//            print("push(\(newArrival))")
            miniStack.append(newArrival)
            //        print("Stack.pop() -> \(currentBest!.fishNumber) : \(currentBest!.fitnessScore!)")
        }

        // String everyone back together such that
        // the guy on top is the same guy who was there before.
        mergeStack(with: miniStack)

        // If we're in retreat mode, then we're looking for the most
        // recent branch in the lineage that will breed better. So
        // no tying scores are accepted.
        if retreatNeeded { candidateFilterType = .bt }
    }

    func mergeStack(with miniStack_: [TSTestSubject]) {
        if miniStack_.isEmpty { return }

        var miniStack = miniStack_.sorted { sortAscending($0, $1) }

        while theStack.first!.fitnessScore! <= miniStack.first!.fitnessScore! {
            miniStack.append(theStack.pop())
        }

        theStack.insert(contentsOf: miniStack, at: 0)
    }

    func updateRetreatStatus(_ formerBenchmarkHolder: TSTestSubject?, _ formerBestScore: Double?) {
        if retreatNeeded {
            var h = "huh?"; if let hh = formerBenchmarkHolder { h = hh.description }
            var s = "sus?"; if let ss = formerBestScore { s = ss.sTruncate() }
            let a = "Could not get \(candidateFilterType.rawValue) for"
            let b = " \(s); discard \(h), retreat to "
            let c = "subject \(currentBenchmarkHolder!.fishNumber)"
            print("\(a)\(b)\(c)")

            retreatLock = currentBenchmarkHolder!.fitnessScore!
            print(retreatLock ?? -43.42, theStack.pop().fitnessScore ?? -42.43)
        } else {
            retreatLock = nil
        }
    }

}

private extension Stack {

    func canAcceptCandidate(_ newArrival: TSTestSubject) -> Bool {
        
        let ctMatchingScore = theStack.filter {
            candidateFilter($0, newArrival)
            }.count
        
        return ctMatchingScore < maxEQScores
    }

    // Start off accepting candidates who merely tied
    func candidateFilter(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        switch self.candidateFilterType {
        case .bt: return winningScore(lhs, rhs)
        case .be: return nonLosingScore(lhs, rhs)
        }
    }
    
    func winningScore(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        guard let Lf = lhs.fitnessScore, let Rf = rhs.fitnessScore else {
            preconditionFailure() }
        //            print("wtf"); return false }
        return Lf < Rf
    }
    
    func nonLosingScore(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        guard let Lf = lhs.fitnessScore, let Rf = rhs.fitnessScore else {
            preconditionFailure() }
        //            print("wtf2"); return false }
        return Lf <= Rf
    }
    
    func sortAscending(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        let Ls = lhs.fitnessScore!, Rs = rhs.fitnessScore!
        let Lf = lhs.fishNumber, Rf = rhs.fishNumber
        
        // If the scores are equal, sort by fish number
        if Ls == Rs { return Lf < Rf }
        
        // If not eq, sort by score
        return Ls < Rs
    }

    // Note!!!! Still sort asc on fish number--we want the
    // first guy who comes in with score n to always be
    // the one we pick first when we have to retreat. Or not.
    func sortDescending(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        let Ls = lhs.fitnessScore!, Rs = rhs.fitnessScore!
        let Lf = lhs.fishNumber, Rf = rhs.fishNumber
        
        if Ls == Rs {
            //print("\(Ls) == \(Rs), \(Lf) > \(Rf)");
            return Lf > Rf
        }
        
        // If not eq, sort by score
//        print("\(Ls) > \(Rs))")
        return Ls > Rs
    }
}
