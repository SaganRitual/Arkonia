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

class ArchiveTests {
    var aboriginal: GSSubjectProtocol?
    var archive: ArchiveProtocol
    let expectedFishNumbers: [Int]
    var goalSuite: GSGoalSuiteProtocol
    let notificationCenter = NotificationCenter.default
    var randomArkonForDisplay: GSSubjectProtocol!
    let selector: SelectorProtocol
    let semaphore = DispatchSemaphore(value: 0)

    public var currentProgenitor: GSSubjectProtocol? { return archive.currentProgenitor }

    init() {
        self.goalSuite = MockGoalSuite()
        self.selector = MockSelector()

        self.archive = Archive(goalSuite: goalSuite)

        let firstFishNumbers = [
            0, 6, 11, 11, 12, 12, 13, 13, 6, 7, 51,
            56, 56, 57, 57, 58, 58, 51, 52, 52, 53, 53,
            7, 8, 8, 0, 0, 0
        ]

        self.expectedFishNumbers = firstFishNumbers + firstFishNumbers.map { $0 + (($0 > 0) ? 140 : 0) }
    }

    let scores: [[Double]] = [
        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // All die; first gen must beat progenitor, no ties allowed
        [ 41.0, 41.0, 41.0, 41.0, 41.0 ],   // + [6, 7, 8], drop last two
        [ 40.0, 40.0, 40.0, 40.0, 40.0 ],   // + [11, 12, 13]
        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // All should be rejected, retry 11
        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // ...backtrack to 12
        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // ...retry 12
        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // ...backtrack to 13
        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // ...retry 13
        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // ...retry 6
        [ 41.0, 41.0, 41.0, 41.0, 41.0 ],   // ...to 7
        [ 40.0, 40.0, 40.0, 40.0, 40.0 ],   // + [51, 52, 53]
        [ 39.0, 39.0, 39.0, 39.0, 39.0 ],   // + [56, 57, 58]
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // retry 56
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // 57 & retry
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // 58 & retry

        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], // Back to 51, who had one try already

        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // 52 & retry
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // 53 & retry
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // retry 7
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // back to 8 & retry
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ],                                     // back to aboriginal
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ],                                     // always stay on aboriginal

        // And make sure we can go all the way through again with a used stack

        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // All die; first gen must beat progenitor, no ties allowed
        [ 41.0, 41.0, 41.0, 41.0, 41.0 ],   // + [6, 7, 8], drop last two
        [ 40.0, 40.0, 40.0, 40.0, 40.0 ],   // + [11, 12, 13]
        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // All should be rejected, retry 11
        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // ...backtrack to 12
        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // ...retry 12
        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // ...backtrack to 13
        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // ...retry 13
        [ 42.0, 42.0, 42.0, 42.0, 42.0 ],   // ...retry 6
        [ 41.0, 41.0, 41.0, 41.0, 41.0 ],   // ...to 7
        [ 40.0, 40.0, 40.0, 40.0, 40.0 ],   // + [51, 52, 53]
        [ 39.0, 39.0, 39.0, 39.0, 39.0 ],   // + [56, 57, 58]
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // retry 56
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // 57 & retry
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // 58 & retry

        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], // Back to 51, who had one try already

        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // 52 & retry
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // 53 & retry
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // retry 7
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ], [ 43.0, 43.0, 43.0, 43.0, 43.0 ],   // back to 8 & retry
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ],                                     // back to aboriginal
        [ 43.0, 43.0, 43.0, 43.0, 43.0 ],                                     // always stay on aboriginal
    ]

    func select() -> GSSubjectProtocol? {

        let aboriginal = goalSuite.factory.getAboriginal()
        aboriginal.fitnessScore = 42.0

        archive.postInit(aboriginal: aboriginal)

        // Line up with the values in our test data arrays
        goalSuite.selectionControls.peerGroupLimit = 3
        goalSuite.selectionControls.hmSpawnAttempts = 2

        for (generation, expectedWinner) in zip(scores, expectedFishNumbers) {
            selectComplete(generation)    // Dummy-posts a bunch of new candidates

            guard let gs = archive.nextProgenitor() else { print("???"); return nil }
            let message = "Expected \(expectedWinner), got \(gs.fishNumber)"
            let condition = (gs.fishNumber == expectedWinner)
            if !condition { print("********************", message) }
            precondition(condition, message)
        }

        return nil
    }

    func selectComplete(_ generation: [Double]) {
        generation.forEach { fitnessScore in
            let subject = MockSubject()
            subject.fitnessScore = fitnessScore
            archive.newCandidate(subject)
        }
    }

    func test() {
        _ = select()
    }
}

class MockGoalSuite: GSGoalSuiteProtocol {
    var factory: GSFactoryProtocol
    var tester: GSTesterProtocol
    var selectionControls: GSSelectionControls

    var description: String { return "MockGoalSuite" }

    init() {
        selectionControls = GSSelectionControls()
        factory = MockFactory()
        tester = MockTester()
    }

    func run() {

    }
}

class MockFactory: GSFactoryProtocol {
    var genomeWorkspace = String()
    let description = "MockFactory"

    func getAboriginal() -> GSSubjectProtocol {
        let m = MockSubject()
        m.postInit(suite: MockGoalSuite())
        return m
    }

    func makeArkon(genome: GenomeSlice, mutate: Bool) -> GSSubjectProtocol? {
        let m = MockSubject()
        m.postInit(suite: MockGoalSuite())
        return m
    }

    func mutate(from: GenomeSlice) { print("mutate") }
}

protocol SelectorProtocol {
    
}

class MockSelector: SelectorProtocol {

}

class MockSubject: GSSubjectProtocol {
    static var theFishNumber = 0

    var fishNumber: Int
    var fitnessScore = 0.0
    var genome: Genome
    var hashedAlready = SetOnce<Int>()
    var spawnCount = 0
    var suite: GSGoalSuiteProtocol?

    var description: String { return genome }

    required init() {
        self.fishNumber = MockSubject.theFishNumber
        MockSubject.theFishNumber += 1

        genome = "Genome for subject \(self.fishNumber)"
    }

    func postInit(suite: GSGoalSuiteProtocol) {
        self.suite = suite
    }

}

class MockTester: GSTesterProtocol {
    var lightLabel: String { return "MockTester" }

    func administerTest(to gs: GSSubjectProtocol) -> Double? {
        return nil
    }

    func postInit(suite: GSGoalSuiteProtocol) {
    }
}
