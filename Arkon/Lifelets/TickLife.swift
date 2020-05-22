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

    required init(_ scratch: Scratchpad) {
        colorizer = Colorizer(scratch)
        super.init(scratch)
    }

    override func launch() {
        Debug.log(level: 167) { "TickLife \(six(scratch.stepper.name))" }
        Debug.debugColor(scratch.stepper, .brown, .blue)
        tick()
    }

    private func tick() { Clock.dispatchQueue.async { self.tickLife(.clock) } }
}

extension TickLife {
    private func tickLife(_ catchDumbMistakes: DispatchQueueID) {
        hardAssert(catchDumbMistakes == .clock)

        scratch.currentTime = Clock.shared!.worldClock
        scratch.currentEntropyPerJoule = Double(1 - Clock.shared!.getEntropy())

        TickLife.dispatchQueue.async { self.tickLife_(.tickLife) }
    }

    private func tickLife_(_ catchDumbMistakes: DispatchQueueID) {
        hardAssert(catchDumbMistakes == .tickLife)

        scratch.stepper.metabolism.digest()

        isAlive = scratch.stepper.metabolism.applyFixedMetabolicCosts()
        canSpawn = Arkonia.allowSpawning && isAlive && scratch.stepper.metabolism.canSpawn()

        if isAlive { colorizer.colorize(routeLife) } else { routeLife_() }
    }
}

extension TickLife {
    private func routeLife() { TickLife.dispatchQueue.async { self.routeLife_() } }

    private func routeLife_() {
        Debug.log(level: 167) { "routeLife \(six(scratch.stepper.name))" }

        hardAssert(Grid.shared.isOnGrid(scratch.stepper.gridCell.gridPosition))

        if !isAlive      { scratch.dispatch!.apoptosize()  }
        else if canSpawn { scratch.dispatch!.spawn()       }
        else             { scratch.dispatch!.computeMove() }
    }
}
