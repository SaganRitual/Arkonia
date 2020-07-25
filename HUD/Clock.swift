import SpriteKit
import SwiftUI

class Clock {
    static var shared = Clock()

    var isRunning = false
    private(set) var worldClock = TimeInterval(0)

    let seasonalFactors = SeasonalFactors()
    let timerDelay = 1 / Arkonia.updateFrequencyHertz

    static let dispatchQueue = DispatchQueue(
        label: "ak.clock.q",
        target: DispatchQueue.global()
    )

    func start() { isRunning = true; tickTheWorld() }

    func getEntropy(_ onComplete: @escaping (CGFloat) -> Void) {
        Clock.dispatchQueue.async {
            self.getEntropy { e in mainDispatch { onComplete(e) } }
        }
    }

    func getEntropy() -> CGFloat {
        guard let t = Arkonia.worldTimeLimit else { return 0 }
        return min(CGFloat(self.worldClock * 2) / CGFloat(t), 1)
    }

    static func getWorldClock(_ onComplete: @escaping (TimeInterval) -> Void) {
        Clock.dispatchQueue.async {
            let c = Clock.shared.worldClock
            onComplete(c)
        }
    }

    static func stop() { Clock.shared.isRunning = false }
}
//
private extension Clock {
    func tickTheWorld() {
        guard isRunning else { return }

        Clock.dispatchQueue.asyncAfter(deadline: .now() + timerDelay, execute: tickTheWorld_B)
    }

    func tickTheWorld_B() {
        self.worldClock += timerDelay
        seasonalFactors.update(self.worldClock)
        tickTheWorld()
    }
}
