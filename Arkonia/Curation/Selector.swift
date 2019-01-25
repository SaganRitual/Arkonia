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

extension Foundation.Notification.Name {
    static let select = Foundation.Notification.Name("select")
    static let selectComplete = Foundation.Notification.Name("selectComplete")
    static let setSelectionParameters = Foundation.Notification.Name("setSelectionParameters")
}

class Selector {
    unowned private var goalSuite: GSGoalSuite
    private let notificationCenter = NotificationCenter.default
    private var observerHandle: NSObjectProtocol?
    private(set) var randomArkonForDisplay: GSSubject?
    unowned private let semaphore: DispatchSemaphore
    weak private var stud: GSSubject!
    private var selectorWorkItem: DispatchWorkItem!
    private var thisGenerationNumber = 0
    private var trackRandomArkon = 0

    init(goalSuite: GSGoalSuite, semaphore: DispatchSemaphore) {
        self.goalSuite = goalSuite
        self.semaphore = semaphore

        let n = Foundation.Notification.Name.setSelectionParameters

        observerHandle = notificationCenter.addObserver(forName: n, object: nil, queue: nil) {
            [unowned self] n in self.setSelectionParameters(n)
        }
    }

    deinit {
        print("Selector deinit")
        selectorWorkItem = nil
        if let ohMy = observerHandle { notificationCenter.removeObserver(ohMy) }
    }

    public func cancel() { semaphore.signal(); selectorWorkItem?.cancel(); }
    public var isCanceled: Bool { return selectorWorkItem.isCancelled }

    private func rLoop() {
        while true {
            if selectorWorkItem.isCancelled { print("rLoop detects cancel"); break }

            defer { semaphore.signal() }

            semaphore.wait()

            guard let newSurvivors = select(against: self.stud) else { continue }
            var selectionResults: [AnyHashable : Any] = [
                NotificationType.selectComplete : newSurvivors
            ]

            if let r = randomArkonForDisplay {
                selectionResults["randomArkonForDisplay"] = r
            }

            let n = Foundation.Notification.Name.selectComplete

            notificationCenter.post(name: n, object: self, userInfo: selectionResults)
        }
    }

    public func scoreAboriginal(_ aboriginal: GSSubject) {
        if goalSuite.tester.administerTest(to: aboriginal) == nil { preconditionFailure() }
    }

    // swiftlint:disable cyclomatic_complexity

    private func select(against stud: GSSubject) -> [GSSubject]? {
        defer { thisGenerationNumber += 1 }

        var bestScore = stud.fitnessScore
        var stemTheFlood = [GSSubject]()

        for _ in 0..<ArkonCentralDark.selectionControls.cSubjectsPerGeneration {
            guard let gs = goalSuite.factory.makeArkon(genome: stud.genome[...], mutate: true) else { continue }

            if selectorWorkItem.isCancelled { break }
            if gs.genome == stud.genome { continue }

            guard let score = goalSuite.tester.administerTest(to: gs) else { continue }

            switch comparisonMode {
            case .ANY: break
            case .BE:  if score > bestScore { continue }
            case .BT:  if score == bestScore { continue }
            case .EQ:  if score != bestScore { continue }
            }

            if score < bestScore { bestScore = score }

            // Start getting rid of the less promising candidates
            if stemTheFlood.count >= ArkonCentralDark.selectionControls.maxKeepersPerGeneration {
                _ = stemTheFlood.popBack()
            }

            stemTheFlood.push(gs)
        }

        if stemTheFlood.isEmpty {
            print("No survivors in generation \(thisGenerationNumber)")
            return nil  // No qualifiers, perhaps even no survivors
        }

//        print("Return \(stemTheFlood.count) test subjects")
        return stemTheFlood
    }

    // swiftlint:enable cyclomatic_complexity

    var comparisonMode = GSGoalSuite.Comparison.BE

    @objc private func setSelectionParameters(_ notification: Notification) {
        guard let u = notification.userInfo,
            let p = u[NotificationType.select] as? GSSubject,
            let e = u["comparisonMode"] else { preconditionFailure() }

        self.stud = p

        guard let c = e as? GSGoalSuite.Comparison else { preconditionFailure() }
        comparisonMode = c
    }

    public func startThread() {

        self.selectorWorkItem = DispatchWorkItem { [weak self] in self!.rLoop()
            self!.selectorWorkItem = nil
        }

        DispatchQueue.global(qos: .background).async(execute: selectorWorkItem)
    }

}
