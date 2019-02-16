import Foundation
import SpriteKit

enum NotificationType: String {
    case selectComplete, select, setSelectionParameters
}

enum CuratorStatus { case running, finished }

class Curator {
    var aboriginal: GSSubject?
    var archive: Archive
    var atLeastOneTSHasSurvived = false
    let displayPortal: SKNode
    var goalSuite: GSGoalSuite
    let notificationCenter = NotificationCenter.default
    var randomArkonForDisplay: GSSubject!
    var remainingGenerations = 0
    let selector: Selector
    let semaphore = DispatchSemaphore(value: 0)

    private var observerHandle: NSObjectProtocol?
    public var status = CuratorStatus.running

    public var currentProgenitor: GSSubject? { return archive.currentProgenitor }

    init(goalSuite: GSGoalSuite) {
        self.selector = Selector(goalSuite: goalSuite, semaphore: semaphore)
        self.goalSuite = goalSuite
        self.archive = Archive(goalSuite: goalSuite)
        self.remainingGenerations = ArkonCentralDark.selectionControls.cGenerations

        self.displayPortal = ArkonCentralLight.display!.getPortal(quadrant: 0)

        let n = Foundation.Notification.Name.selectComplete
        observerHandle = notificationCenter.addObserver(forName: n, object: selector, queue: nil) {
            [unowned self] notification in self.selectComplete(notification)
        }

        self.selector.startThread()
    }

    deinit {
        selector.cancel()

        if let oh = observerHandle {
            notificationCenter.removeObserver(oh); print("Curator deinit")
        }
    }

    func deploySelector(reference gs: GSSubject) {
        let n1 = Foundation.Notification.Name.setSelectionParameters
        let q1 = [NotificationType.select : gs, "comparisonMode" : archive.comparisonMode] as [AnyHashable : Any]
        let p1 = Foundation.Notification(name: n1, object: nil, userInfo: q1)

        let n2 = Foundation.Notification.Name.select
        let p2 = Foundation.Notification(name: n2, object: nil, userInfo: nil)

        notificationCenter.post(p1)
        notificationCenter.post(p2)

        semaphore.signal()  // Everything is in place; selector, go fetch
    }

    func select() -> GSSubject? {
        let a = goalSuite.factory.getAboriginal()

        selector.scoreAboriginal(a)
        archive.postInit(aboriginal: a)

        // Display the aboriginal
        nok(ArkonCentralLight.display).display(a.kNet!, portal: displayPortal)

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
                nok(ArkonCentralLight.display).display(gs.kNet!, portal: displayPortal)
                print("New record by \(gs.fishNumber): \(gs.fitnessScore)")
                gs.genome.dump(gs.fishNumber, gs.fitnessScore)
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
                " genome \(String(describing: currentProgenitor?.genome))")

//        print((self.currentProgenitor as! AASubject).debugOutput)

        return self.currentProgenitor
    }

    @objc func selectComplete(_ notification: Notification) {
        guard let u = notification.userInfo,
            let p = u[NotificationType.selectComplete] as? [GSSubject]
//            let q = u["randomArkonForDisplay"] as? GSSubject
            else {
//                print("u", terminator: "")
                if !self.selector.isCanceled { return }
                preconditionFailure()
            }

//        print("s", terminator: "")
//        randomArkonForDisplay = q
        p.forEach { archive.newCandidate($0) }
        self.atLeastOneTSHasSurvived = true
    }
}
