import CoreGraphics
import Foundation

final class TickLife: Dispatchable {
    var isAlive = false
    var canSpawn = false
    var colorizer: Colorizer!
    var onComplete: ((Bool, Bool) -> Void)?

    static let dispatchQueue = DispatchQueue(
        label: "ak.ticklife.q",
        attributes: .concurrent,
        target: DispatchQueue.global()
    )

    override func launch() {
        Debug.log(level: 167) { "TickLife \(six(scratch.stepper.name))" }
        Debug.debugColor(scratch.stepper, .yellow, .blue)

        colorizer = Colorizer(scratch)
        tick()
    }

    private func tick() { Clock.dispatchQueue.async { self.tickLife(.clock) } }
}

extension TickLife {
    private func tickLife(_ catchDumbMistakes: DispatchQueueID) {
        assert(catchDumbMistakes == .clock)

        scratch.currentTime = Clock.shared!.worldClock
        scratch.currentEntropyPerJoule = Double(1 - Clock.shared!.getEntropy())

        TickLife.dispatchQueue.async { self.tickLife_(.tickLife) }
    }

    private func tickLife_(_ catchDumbMistakes: DispatchQueueID) {
        assert(catchDumbMistakes == .tickLife)

        scratch.stepper.metabolism.digest()

        isAlive = scratch.stepper.metabolism.applyFixedMetabolicCosts()
        canSpawn = isAlive && scratch.stepper.metabolism.canSpawn()

        if isAlive { colorizer = Colorizer(scratch); colorizer.colorize(routeLife) } else { routeLife() }
    }
}

extension TickLife {
    private func routeLife() {
        Debug.log(level: 167) { "routeLife \(six(scratch.stepper.name))" }

        precondition(Grid.shared.isOnGrid(scratch.stepper.gridCell.gridPosition))

        if !isAlive      { scratch.dispatch!.apoptosize()  }
        else if canSpawn { scratch.dispatch!.spawn()       }
        else             { scratch.dispatch!.computeMove() }
    }
}
