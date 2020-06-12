import CoreGraphics
import Foundation

extension Stepper {
    func tickLife() {
        var isAlive = false
        var canSpawn = false
        var onComplete: ((Bool, Bool) -> Void)?

        func tickLife_A() { Clock.dispatchQueue.async(execute: tickLife_B) }
        func tickLife_B() {
            Debug.log(level: 206) { "tickLife_A \(six(name))" }
            Debug.debugColor(self, .green, .blue)

            currentTime = Clock.shared!.worldClock
            currentEntropyPerJoule = Double(1 - Clock.shared!.getEntropy())

            MainDispatchQueue.async(execute: tickLife_C)
        }

        func tickLife_C() {
            metabolism.digest()
            isAlive = metabolism.applyFixedMetabolicCosts()

            if !isAlive { Debug.log(level: 205) { "apoptosizing" } }

            if !isAlive { apoptosize(); return }

            canSpawn = Arkonia.allowSpawning && isAlive && metabolism.canSpawn()

            if canSpawn { Debug.log(level: 205) { "spawning" } }
            else        { Debug.log(level: 205) { "driveNetSignaling" } }

            if canSpawn { Stepper.makeNewArkon(self); return }

            colorize(driveNetSignal)
        }

        tickLife_A()
    }
}
