import CoreGraphics
import Foundation

extension Stepper {
    func tickLife() {
        var isAlive = false
        var canSpawn = false

        Clock.dispatchQueue.async { tickLife_A() }

        func tickLife_A() {
            Debug.log(level: 213) { "tickLife_A \(name)" }
            Debug.debugColor(self, .green, .blue)

            currentTime = Clock.shared!.worldClock
            currentEntropyPerJoule = Double(1 - Clock.shared!.getEntropy())

            mainDispatch(tickLife_B)
        }

        func tickLife_B() {
            metabolism.digest()
            isAlive = metabolism.applyFixedMetabolicCosts()

            if !isAlive { Debug.log(level: 205) { "apoptosizing" } }

            if !isAlive { apoptosize(disengageAll: true); return }

            canSpawn = Arkonia.allowSpawning && isAlive && metabolism.canSpawn()

            if canSpawn { Debug.log(level: 213) { "spawning" } }
            else        { Debug.log(level: 213) { "driveNetSignaling" } }

            if canSpawn { Stepper.makeNewArkon(self); return }

            colorize(driveNetSignal)
        }
    }
}
