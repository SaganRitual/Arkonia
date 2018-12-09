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
    var aboriginal: TSTestSubject!
    var archive = Archive()
    var atLeastOneTSHasSurvived = false
    let notificationCenter = NotificationCenter.default
    var remainingGenerations = 0
    let selector: Selector
    let semaphore = DispatchSemaphore(value: 0)
    let tsFactory: TestSubjectFactory
    private var observerHandle: NSObjectProtocol?
    public var status = CuratorStatus.running

    public var currentTS: TSTestSubject? { return archive.referenceTS }

    init(tsFactory: TestSubjectFactory) {
        
        self.tsFactory = tsFactory
        self.selector = Selector(tsFactory: tsFactory, semaphore: semaphore)

        // This has to happen after the Selector init,
        // because the Selector calls into the tsFactory
        // which inits the fitness tester, which sets the
        // controls. Seems rather ugly. Come back to it.
        self.remainingGenerations = selectionControls.howManyGenerations
        
        let n = Foundation.Notification.Name.selectComplete
        observerHandle = notificationCenter.addObserver(forName: n, object: selector, queue: nil) {
            [unowned self] notification in self.selectComplete(notification)
        }

        self.selector.startThread()
    }

    deinit {
        if let oh = observerHandle {
            notificationCenter.removeObserver(oh); print("Curator deinit")
        }
    }

    func select() -> TSTestSubject? {

        guard let a = Statics.makePromisingAboriginal(factory: tsFactory)
            else { return nil }

        selector.scoreAboriginal(a)
        archive.postInit(aboriginal: a)

        self.aboriginal = a
        self.atLeastOneTSHasSurvived = true
        print("Aboriginal score = \(a.fitnessScore!)")

        var firstPass = true

        while remainingGenerations > 0 {
            defer { remainingGenerations -= 1 }

            // We skip waiting on the first pass because the thread is
            // currently waiting for it; we don't want to block. After this
            // pass, the Curator and the thread will take turns by passing
            // the semaphore back and forth.
            if !firstPass { semaphore.wait() }

            let ts = archive.nextProgenitor()
            let newScore = ts.fitnessScore ?? -Double.infinity
            let oldScore = archive.referenceTS?.fitnessScore ?? Double.infinity
            if newScore != oldScore {
                print("New record by \(ts.fishNumber): \(ts.fitnessScore!)")
            }

            let n1 = Foundation.Notification.Name.setSelectionParameters
            let q1 = [NotificationType.select : ts, "comparisonMode" : archive.comparisonMode] as [AnyHashable : Any]
            let p1 = Foundation.Notification(name: n1, object: nil, userInfo: q1)

            let n2 = Foundation.Notification.Name.select
            let p2 = Foundation.Notification(name: n2, object: nil, userInfo: nil)

            notificationCenter.post(p1)
            notificationCenter.post(p2)

            semaphore.signal()  // Everything is in place; start the selector running

            firstPass = false
            if let f = self.currentTS?.fitnessScore, f == 0.0 { break }
        }

        // We're moving, of course, so the selector will be
        // waiting for the semaphore

        semaphore.signal()
        selector.cancel()
        status = .finished
        print("Best score \(self.currentTS?.fitnessScore ?? -42.4242)" +
                " from \(self.currentTS?.fishNumber ?? 424242)," +
                " genome \(currentTS?.genome ?? "<no genome?>")")
        return self.currentTS
    }

    @objc func selectComplete(_ notification: Notification) {
        guard let u = notification.userInfo,
            let p = u[NotificationType.selectComplete] as? TSArray
            else {
                if !self.selector.isCanceled { return }
                preconditionFailure()
            }

        p.forEach { archive.newCandidate($0) }
        self.atLeastOneTSHasSurvived = true
    }
}

extension Array {
    // It's easier for me to think about the breeders as a stack
    mutating func pop() -> Element { return self.removeFirst() }
    mutating func push(_ e: Element) { self.insert(e, at: 0) }
    mutating func popBack() -> Element { return self.removeLast() }
    mutating func pushFront(_ e: Element) { push(e) }
}
