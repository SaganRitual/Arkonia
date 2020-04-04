import Foundation

extension Funge {
    class TickLife {
        var isAlive = false
        var canSpawn = false
        var currentTime = 0
        var onComplete: ((Bool, Bool) -> Void)?
        let stepper: Stepper

        init(_ stepper: Stepper) { self.stepper = stepper }
    }
}

extension Funge.TickLife {
    func tick(_ onComplete: @escaping (Bool, Bool) -> Void) {
        self.onComplete = onComplete
        Clock.getWorldClock(tickLife)
    }

    func tock(_ isAlive: Bool, _ canSpawn: Bool) {
        onComplete!(isAlive, canSpawn)
    }
}

extension Funge.TickLife {
    private func tickLife(_ currentTime: Int) {
        self.currentTime = currentTime

        Funge.dispatchQueue.async(execute: tickLife_)
    }

    private func tickLife_() {
        let isAlive = stepper.metabolism.fungeProper(
            cNeurons: stepper.net!.cNeurons,
            co2Counter: stepper.dispatch.scratch.co2Counter,
            cOffspring: stepper.cOffspring,
            currentTime: currentTime
        )

        let canSpawn = stepper.canSpawn()

        tock(isAlive, canSpawn)
    }
}
