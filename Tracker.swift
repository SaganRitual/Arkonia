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

public enum CompareFunctionOperator: String { case BE, BT, EQ }

fileprivate typealias CompareFunction = (TSTestSubject, TSTestSubject) -> Bool

fileprivate extension Array where Element == TSTestSubject {

    func countNonLosers(against benchmark: TSTestSubject) -> Int {
        return countQualifiers(against: benchmark, .BE)
    }

    private func countQualifiers(against benchmark: TSTestSubject, _ op: CompareFunctionOperator) -> Int {
        return self.filter({ return isAcceptable($0, op: op, against: benchmark.fitnessScore!) }).count
    }

    func countTies(against benchmark: TSTestSubject) -> Int {
        return countQualifiers(against: benchmark, .EQ)
    }

    func countWinners(against benchmark: TSTestSubject) -> Int {
        return countQualifiers(against: benchmark, .BT)
    }

    func isAcceptable(_ testSubject: TSTestSubject, op: CompareFunctionOperator, against score: Double) -> Bool {
        switch op {
        case .BE: return testSubject.fitnessScore! <= score
        case .BT: return testSubject.fitnessScore! < score
        case .EQ: return testSubject.fitnessScore! == score
        }
    }
}

fileprivate class Stack: CustomStringConvertible {
    // Famous last words: 25 generations will be far more than enough
    private let stackSize = selectionControls.keepersPerGenerationLimit * 25
    private var theStack = [TSTestSubject?]()
    private var description_ = String()

    var count: Int { return theStack.count }
    var isEmpty: Bool { return theStack.isEmpty }

    var description: String {
        description_.removeAll(keepingCapacity: true)

        description_ += "Stack -- depth \(theStack.count)\n"
        theStack.forEach {
            guard let ts = $0 else { preconditionFailure() }

            description_ += "TS \(ts.fishNumber) score \(ts.fitnessScore!)\n"
        }

        return description_
    }

    init() { theStack.reserveCapacity(stackSize) }

    func countKeepers(against benchmark: TSTestSubject, _ op: CompareFunctionOperator) -> Int {
        return theStack.compactMap({$0!}).countNonLosers(against: benchmark)
    }

    func countTies(against benchmark: TSTestSubject, _ compareFunction: CompareFunctionOperator) -> Int {
        return theStack.compactMap({$0!}).countTies(against: benchmark)
    }

    func countWinners(against benchmark: TSTestSubject, _ compareFunction: CompareFunctionOperator) -> Int {
        return theStack.compactMap({$0!}).countWinners(against: benchmark)
    }

    public func isAcceptable(_ testSubject: TSTestSubject, op: CompareFunctionOperator, against score: Double) -> Bool {
        return theStack.compactMap({$0}).isAcceptable(testSubject, op: op, against: score)
    }

    public func multiPush(_ pushees: [TSTestSubject]) { theStack.append(contentsOf: pushees) }

    public func pop() -> TSTestSubject { return theStack.removeLast()! }

    public func postInit(aboriginal: TSTestSubject) { push(aboriginal) }

    public func push(_ testSubject: TSTestSubject) { theStack.append(testSubject) }

    public func top() -> TSTestSubject { return theStack.last!! }
}

class Tracker {
    private var compareFunctionOperator = CompareFunctionOperator.BE
    private var currentBenchmark: TSTestSubject!
    private var testSubjectDisposition = TestSubjectDisposition.winner
    private var dudlinessCount = 0
    private var highWaterMark: TSTestSubject!
    private let maxNonLosersPerScore = selectionControls.stackTieScoresLimit
    private var miniStack = [TSTestSubject]()
    private let miniStackCapacity: Int
    private var stack = Stack()

    init() {
        miniStackCapacity = maxNonLosersPerScore * 2
        miniStack.reserveCapacity(miniStackCapacity)
    }

    private func backtrack() -> (TSTestSubject, TestSubjectDisposition) {
        compareFunctionOperator = .BT   // While backtracking, we don't take ties
        _ = stack.pop() // Get rid of the loafer
        currentBenchmark = stack.top()//; print("popped \(loafer.fishNumber), score \(loafer.fitnessScore!)")
        dudlinessCount = 0      // Give the guy a chance to prove himself
        testSubjectDisposition = .backtrack
        backtracking = true

        print("Backtracked to \(currentBenchmark.fishNumber)\n\(stack)")

        return (currentBenchmark, testSubjectDisposition)
    }

    public func getSelectionParameters() -> (TSTestSubject, CompareFunctionOperator, TestSubjectDisposition) {
        return (currentBenchmark, compareFunctionOperator, self.testSubjectDisposition)
    }

    fileprivate func isKeeper(_ testSubject: TSTestSubject) -> Bool {
        return isKeeper(testSubject, op: compareFunctionOperator, against: currentBenchmark.fitnessScore!)
    }

    fileprivate func isKeeper(_ testSubject: TSTestSubject, op: CompareFunctionOperator, against score: Double) -> Bool {
        return stack.isAcceptable(testSubject, op: op, against: score)
    }

    public func postInit(aboriginal: TSTestSubject) {
        currentBenchmark = aboriginal
        highWaterMark = aboriginal

        stack.postInit(aboriginal: aboriginal)
    }

    var backtracking = false

    public func track(_ newGuys: [TSTestSubject]) -> (TSTestSubject, TestSubjectDisposition) {
        let c = compareFunctionOperator
        let s = currentBenchmark.fitnessScore!
        for newGuy in newGuys
            where newGuys.isAcceptable(newGuy, op: c, against: s) && withinKeeperQuotas(newGuy) {
            miniStack.append(newGuy)
        }

        while !stack.isEmpty && isKeeper(stack.top()) {
            let p = stack.pop()
            miniStack.append(p)
        }

        miniStack.sort { sortDescending($0, $1) }
        stack.multiPush(miniStack)

        miniStack.removeAll(keepingCapacity: true)

        let ts = stack.top()
        if ts == currentBenchmark {
            dudlinessCount += 1
            testSubjectDisposition = .sameGuy
        } else {
            backtracking = false
            dudlinessCount = 0
            testSubjectDisposition = .winner
            if ts.fitnessScore! < highWaterMark.fitnessScore! {
                highWaterMark = ts
            }
        }

        var newCurrentTestSubject = ts, disposition = testSubjectDisposition,
            newCompareFunctionOperator = CompareFunctionOperator.BE

        if dudlinessCount >= selectionControls.dudlinessThreshold {
            (newCurrentTestSubject, disposition) = backtrack()

            // When backtracking, ignore equal scores. To be worth
            // pursuing their lineage, they have to produce someone
            // who can beat the record set by their cousins.
            newCompareFunctionOperator = .BT
        }

        currentBenchmark = newCurrentTestSubject
        compareFunctionOperator = newCompareFunctionOperator

        print("top: \(newCurrentTestSubject)")
        return (newCurrentTestSubject, disposition)
    }

    private func withinKeeperQuotas(_ testSubject: TSTestSubject) -> Bool {
        let newTies = miniStack.countTies(against: testSubject)
        let newWinners = miniStack.countWinners(against: testSubject)
        let oldTies = stack.countTies(against: testSubject, compareFunctionOperator)
        let oldWinners = stack.countWinners(against: testSubject, compareFunctionOperator)

        let isWinner = testSubject.fitnessScore! < currentBenchmark.fitnessScore!
        if isWinner { return (oldWinners + newWinners) < maxNonLosersPerScore }

        return (oldTies + newTies) < maxNonLosersPerScore
    }

}

extension Tracker {
    enum TestSubjectDisposition: String { case winner, sameGuy, backtrack }

    private func countKeepers(_ testSubject: TSTestSubject, _ op: CompareFunctionOperator) -> Int {
        return stack.countKeepers(against: testSubject, op)
    }

    private func countTies(_ testSubject: TSTestSubject, _ op: CompareFunctionOperator) -> Int {
        return stack.countTies(against: testSubject, op)
    }

    private func countWinners(_ testSubject: TSTestSubject, _ op: CompareFunctionOperator) -> Int {
        return stack.countWinners(against: testSubject, op)
    }

    private func sortAscending(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        let Ls = lhs.fitnessScore!, Rs = rhs.fitnessScore!
        let Lf = lhs.fishNumber, Rf = rhs.fishNumber

        // If the scores are equal, sort by fish number
        if Ls == Rs { return Lf < Rf }

        // If not eq, sort by score
        return Ls < Rs
    }

    private func sortDescending(_ lhs: TSTestSubject, _ rhs: TSTestSubject) -> Bool {
        let Ls = lhs.fitnessScore!, Rs = rhs.fitnessScore!
        let Lf = lhs.fishNumber, Rf = rhs.fishNumber

        if Ls == Rs { return Lf > Rf }

        return Ls > Rs
    }

    func winningScore(_ lhs: TSTestSubject, _ rhs: Double) -> Bool {
        guard let Lf = lhs.fitnessScore else {
            preconditionFailure() }

        return Lf < rhs
    }

    func nonLosingScore(_ lhs: TSTestSubject, _ rhs: Double) -> Bool {
        guard let Lf = lhs.fitnessScore else {
            preconditionFailure() }

        return Lf <= rhs
    }
}
