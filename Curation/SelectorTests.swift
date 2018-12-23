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

enum NotificationType: String {
    case selectComplete, select, setSelectionParameters
}

enum CuratorStatus { case running, finished }

protocol TestableProtocol {
    func test()
}

class SelectorTests {
    var aboriginal: GSSubjectProtocol?
    var archive: ArchiveProtocol
    var atLeastOneTSHasSurvived = false
    var goalSuite: GSGoalSuiteProtocol
    let notificationCenter = NotificationCenter.default
    var randomArkonForDisplay: GSSubjectProtocol!
    var remainingGenerations = 0
    let selector: Selector
    let semaphore = DispatchSemaphore(value: 0)
    var workItem: DispatchWorkItem!

    private var observerHandle: NSObjectProtocol?
    public var status = CuratorStatus.running

    public var currentProgenitor: GSSubjectProtocol? { return archive.currentProgenitor }

    init() {
        let goalSuite = MockGoalSuite()
        self.selector = Selector(goalSuite: goalSuite, semaphore: semaphore)
        self.archive = MockArchive(goalSuite: goalSuite)
        self.remainingGenerations = goalSuite.selectionControls.howManyGenerations

        self.goalSuite = goalSuite

        let n = Foundation.Notification.Name.selectComplete
        observerHandle = notificationCenter.addObserver(forName: n, object: selector, queue: nil) {
            [unowned self] notification in self.selectComplete(notification)
        }

        self.selector.startThread()
    }

    func deploySelector(reference gs: GSSubjectProtocol) {
        let n1 = Foundation.Notification.Name.setSelectionParameters
        let q1 = [NotificationType.select : gs, "comparisonMode" : archive.comparisonMode] as [AnyHashable : Any]
        let p1 = Foundation.Notification(name: n1, object: nil, userInfo: q1)

        let n2 = Foundation.Notification.Name.select
        let p2 = Foundation.Notification(name: n2, object: nil, userInfo: nil)

        notificationCenter.post(p1)
        notificationCenter.post(p2)

        semaphore.signal()  // Everything is in place; selector, go fetch
    }

    func select() -> GSSubjectProtocol? {
        let a = goalSuite.factory.getAboriginal()
        selector.scoreAboriginal(a)
        archive.postInit(aboriginal: a)

        self.aboriginal = a
        self.atLeastOneTSHasSurvived = true
        print("Aboriginal score = \(a.fitnessScore)")

        var firstPass = true

        while remainingGenerations > 0 {
            defer { remainingGenerations -= 1 }

            // We skip waiting on the first pass because the thread is
            // currently waiting for it; we don't want to block. After this
            // pass, the Curator and the thread will take turns by passing
            // the semaphore back and forth.
            if !firstPass { semaphore.wait() }

            guard let gs = archive.nextProgenitor() else {
                print("???"); return nil }

            let newScore = gs.fitnessScore
            let oldScore = archive.referenceTS!.fitnessScore
            if newScore != oldScore {
                //                if let zts = gs as? TSLearnZoeName {
                //                    print("New record by \(gs.fishNumber): \"\(zts.attemptedZName)\"")
                //                } else {
                print("New record by \(gs.fishNumber): \(gs.fitnessScore)")
                //                print(gs.genome)
                //                }
            }

            deploySelector(reference: gs)

            firstPass = false
            if let f = self.currentProgenitor?.fitnessScore, f == 0.0 { break }
        }

        // We're moving, of course, so the selector will be
        // waiting for the semaphore

        semaphore.signal()
        selector.cancel()
        status = .finished
        print("Best score \(self.currentProgenitor?.fitnessScore ?? -42.4242)" +
            " from \(self.currentProgenitor?.fishNumber ?? 424242)," +
            " genome \(currentProgenitor?.genome ?? "<no genome?>")")
        return self.currentProgenitor
    }

    @objc func selectComplete(_ notification: Notification) {
        guard let u = notification.userInfo,
            let p = u[NotificationType.selectComplete] as? [GSSubjectProtocol]
            else {
                if !self.selector.isCanceled { return }
                preconditionFailure()
        }

        if let d = p.last { randomArkonForDisplay = d }
        p.forEach { archive.newCandidate($0) }
        self.atLeastOneTSHasSurvived = true
    }

    func test() { _ = select() }
}

class MockArchive: ArchiveProtocol {

    typealias GroupIndex = Int

    var comparisonMode = GSComparison.BE
    var currentProgenitor: GSSubjectProtocol?
    var referenceTS: GSSubjectProtocol?
    internal var theArchive = [GroupIndex : GSSubjectProtocol]()
    internal var theIndex = [Int]()

    required init(goalSuite: GSGoalSuiteProtocol) {
    }

    func advance(_ gs: GSSubjectProtocol) {
        let hash = gs.fishNumber

        theArchive[hash]! = gs

        // Accept ties until our bucket for this hash is full
        setQualifications(reference: gs, op: .BE)
    }

    func getTop() -> GSSubjectProtocol? {
        if theIndex.isEmpty { return nil }
        let gIndex = theIndex.removeLast()
        let gs = theArchive[gIndex]
        return gs
    }

    func newCandidate(_ gs: GSSubjectProtocol) {
        theIndex.append(gs.fishNumber)
        theArchive[gs.fishNumber] = gs
        print("index", theIndex)
        print("archive", theArchive)
    }

    func nextProgenitor() -> GSSubjectProtocol? {
        return getTop()
    }

    func postInit(aboriginal: GSSubjectProtocol) {
        theArchive[aboriginal.fishNumber] = aboriginal
        theIndex.append(aboriginal.fishNumber)
        setQualifications(reference: aboriginal, op: .BT)
    }

    func setQualifications(reference gs: GSSubjectProtocol, op: GSComparison) {
        referenceTS = gs; comparisonMode = op
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

    func mutate(from: GenomeSlice) {
        print("mutate")
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

class MockSubject: GSSubjectProtocol {
    private static var theFishNumber = 0

    var description = "MockSubject"
    var fishNumber: Int
    var fitnessScore = 0.0
    var genome = Genome()
    var spawnCount = 0
    var suite: GSGoalSuiteProtocol?

    required init() {
        self.fishNumber = MockSubject.theFishNumber; MockSubject.theFishNumber += 1
    }

    func postInit(suite: GSGoalSuiteProtocol) { self.suite = suite }
}

class MockTester: GSTesterProtocol {
    static var dummyScore = 42.42
    static var fluctator = 10
    static var fluctuatorSign = -1
    var lightLabel = "MockTester light label"

    func administerTest(to gs: GSSubjectProtocol) -> Double? {
        gs.fitnessScore = MockTester.dummyScore

        MockTester.fluctator -= 1
        if MockTester.fluctator <= 0 {
            var q = MockTester.fluctuatorSign
            q += 1; if q > 1 { q = -1 }
            MockTester.fluctuatorSign = q

            MockTester.fluctator = Int.random(in: 0..<10)
        }

        MockTester.dummyScore += Double(MockTester.fluctuatorSign) * 0.000001

        gs.fitnessScore = MockTester.dummyScore
        gs.genome = "\(gs.fitnessScore)"
//        print("twat", gs.fishNumber, gs.fitnessScore)

        return gs.fitnessScore
    }

    func postInit(suite: GSGoalSuiteProtocol) {
    }
}
