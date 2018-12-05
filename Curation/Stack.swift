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

    private var theStack = TSArray()

    private var maxEQScores = selectionControls.stackNoobsLimit
    private var retreatLock: Double?

    public var count: Int { return theStack.count }

    public func pop() -> TSTestSubject { return theStack.pop() }
    public func push(_ ts: TSTestSubject) { theStack.push(ts) }
    public func popBack() { _ = theStack.popBack() }

    // Start off accepting candidates who merely tied
    public func candidateFilter(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        switch self.candidateFilterType {
        case .bt: return winningScore(lhs, rhs)
        case .be: return nonLosingScore(lhs, rhs)
        }
    }

    private func winningScore(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        guard let Lf = lhs.fitnessScore, let Rf = rhs.fitnessScore else {
            preconditionFailure() }
//            print("wtf"); return false }
        return Lf < Rf
    }

    private func nonLosingScore(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        guard let Lf = lhs.fitnessScore, let Rf = rhs.fitnessScore else {
            preconditionFailure() }
//            print("wtf2"); return false }
        return Lf <= Rf
    }

    private var retreatTimer = 0

    var candidateFilterType = CandidateFilter.be

    public func getSelectionParameters() -> (TSTestSubject, CandidateFilter) {
        guard let cb = currentBenchmarkHolder else { fatalError() }
        let cf = self.candidateFilterType
        return (cb, cf)
    }

    func postInit(aboriginal: TSTestSubject) {
        currentBenchmarkHolder = aboriginal
        highWaterHolder = aboriginal
    }

    func sortAscending(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        let Ls = lhs.fitnessScore!, Rs = rhs.fitnessScore!
        let Lf = lhs.fishNumber, Rf = rhs.fishNumber

        // If the scores are equal, sort by fish number
        if Ls == Rs { return Lf < Rf }

        // If not eq, sort by score
        return Ls < Rs
    }

    func sortDescending(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        let Ls = lhs.fitnessScore!, Rs = rhs.fitnessScore!
        let Lf = lhs.fishNumber, Rf = rhs.fishNumber

        // If the scores are equal, sort by fish number
        if Ls == Rs { return Lf > Rf }

        // If not eq, sort by score
        return Ls > Rs
    }

    func stack(_ na: TSArray) {
        var currentBestScore = Double.infinity
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

        var retreated = true

        func canAcceptCandidate(_ newArrival: TSTestSubject) -> Bool {

            let ctMatchingScore = theStack.filter {
                candidateFilter($0, newArrival)
            }.count

            return ctMatchingScore < maxEQScores
        }

//        print("theStack", theStack)
//        print("newArrivals", newArrivals)

        candidateFilterType = .be
        for newArrival in newArrivals where canAcceptCandidate(newArrival) {
            guard let score = newArrival.fitnessScore else { preconditionFailure() }
            if let rL = retreatLock, score >= rL { continue }

            // We're full up on people matching the current
            // score; ignore everyone until we get one that
            // beats it.
            candidateFilterType = .bt
            retreated = false
            retreatLock = nil

            let ctMatchingScore = theStack.filter {
                candidateFilter($0, newArrival)
            }.count

            guard ctMatchingScore < maxEQScores else { continue }

            // We come here if we're still under the limit for
            // matching scores, or if we're processing test subjects
            // that have better scores
//            print("Stack.push( \(newArrival.fishNumber): \(newArrival.fitnessScore!))")
            precondition(newArrival.debugMarker == 424242)
//            print("f(\(newArrival.fishNumber)), V(\(newArrival.brain.allLayersConnected)) ", terminator: "")
            theStack.push(newArrival)
        }

//        print("theStack after, sort of", theStack)
        currentBenchmarkHolder = theStack.pop()
        currentBestScore = currentBenchmarkHolder!.fitnessScore!

       if retreated {
           print("Could not get \(candidateFilterType.rawValue) for \(currentBestScore); retreating to ", terminator: "")
           if retreatLock == nil { if !theStack.isEmpty { print("subject \(currentBenchmarkHolder!.fishNumber)") }; retreatLock = currentBenchmarkHolder!.fitnessScore! }
           if theStack.isEmpty { print("aboriginal"); retreatLock = nil }
       } else {
//            print("Trying to match/beat \(currentBestScore) or whaatevs \(wtfScore)")
           retreatLock = nil
       }

//        print("Stack.pop() -> \(currentBest!.fishNumber) : \(currentBest!.fitnessScore!)")
    }
}
