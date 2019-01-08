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

class Curator {
    var aboriginal: GSSubject?
    var archive: Archive
    var atLeastOneTSHasSurvived = false
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
        self.remainingGenerations = ArkonCentral.sel.howManyGenerations

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

        self.aboriginal = a
        self.atLeastOneTSHasSurvived = true
        print("Aboriginal score = \(a.fitnessScore)")

        let gameScene = ArkonCentral.gScene!
        gameScene.makeVGrid(self.aboriginal!.kNet!)

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
                print("New record by \(gs.fishNumber): \(gs.fitnessScore)")

                let gameScene = ArkonCentral.gScene!
                gameScene.makeVGrid(gs.kNet!)

//                print((self.currentProgenitor as! AASubject).debugOutput)
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

//        print((self.currentProgenitor as! AASubject).debugOutput)

        return self.currentProgenitor
    }

    @objc func selectComplete(_ notification: Notification) {
        guard let u = notification.userInfo,
            let p = u[NotificationType.selectComplete] as? [GSSubject]
//            let q = u["randomArkonForDisplay"] as? GSSubject
            else {
                print("u", terminator: "")
                if !self.selector.isCanceled { return }
                preconditionFailure()
            }

        print("s", terminator: "")
//        randomArkonForDisplay = q
        p.forEach { archive.newCandidate($0) }
        self.atLeastOneTSHasSurvived = true
    }
}
