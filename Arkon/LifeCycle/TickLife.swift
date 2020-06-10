import CoreGraphics
import Foundation

final class TickLife: Dispatchable {
    var isAlive = false
    var canSpawn = false
    let colorizer: Colorizer
    var onComplete: ((Bool, Bool) -> Void)?

    static let dispatchQueue = DispatchQueue(
        label: "ak.ticklife.q",
        attributes: .concurrent,
        target: DispatchQueue.global()
    )

    required init(_ stepper: Stepper?) {
        colorizer = Colorizer(stepper!)
        super.init(stepper!)
    }

    override func launch() {
        Debug.debugColor(stepper, .brown, .blue)
        tick()
    }

    private func tick() { Clock.dispatchQueue.async(execute: tickLife_A) }
}

extension TickLife {
    private func tickLife_A() {
        Debug.log(level: 190) { "tickLife_A \(six(stepper.name))" }
        stepper.currentTime = Clock.shared!.worldClock
        stepper.currentEntropyPerJoule = Double(1 - Clock.shared!.getEntropy())

        TickLife.dispatchQueue.async(execute: tickLife_B)
    }

    private func tickLife_B() {
        Debug.log(level: 190) { "tickLife_B \(six(stepper.name))" }

        stepper.metabolism.digest()
        isAlive = stepper.metabolism.applyFixedMetabolicCosts()

        if !isAlive { stepper.dispatch!.apoptosize(); return }

        canSpawn = Arkonia.allowSpawning && isAlive && stepper.metabolism.canSpawn()
        colorizer.colorize(routeLife_A)
    }
}

extension TickLife {
    private func routeLife_A() { TickLife.dispatchQueue.async { self.routeLife_B() } }

    private func routeLife_B() {
        Debug.log(level: 167) { "routeLife \(six(stepper.name))" }

        if canSpawn { stepper.dispatch!.spawn()       }
        else        { stepper.dispatch!.driveNetSignal() }
    }
}
