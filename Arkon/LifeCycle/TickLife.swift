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

    private func tick() { Clock.dispatchQueue.async(execute: tickLife) }
}

extension TickLife {
    private func tickLife() {
        Debug.log(level: 190) { "tickLife_A \(six(stepper.name))" }
        Debug.debugColor(stepper, .green, .blue)

        stepper.currentTime = Clock.shared!.worldClock
        stepper.currentEntropyPerJoule = Double(1 - Clock.shared!.getEntropy())

        stepper.metabolism.digest()
        isAlive = stepper.metabolism.applyFixedMetabolicCosts()

        if !isAlive { stepper.dispatch.apoptosize(); return }

        canSpawn = Arkonia.allowSpawning && isAlive && stepper.metabolism.canSpawn()

        let route = canSpawn ?
            stepper.dispatch.spawn : stepper.dispatch.driveNetSignal

        colorizer.colorize(route)
    }
}
