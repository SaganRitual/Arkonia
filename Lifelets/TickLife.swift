import CoreGraphics
import Foundation

final class TickLife: Dispatchable {
    var isAlive = false
    var canSpawn = false
    var onComplete: ((Bool, Bool) -> Void)?

    static let dispatchQueue = DispatchQueue(
        label: "ak.ticklife.q",
        attributes: .concurrent,
        target: DispatchQueue.global()
    )

    override func launch() {
        Debug.log(level: 167) { "TickLife \(six(scratch.stepper.name))" }
        Debug.debugColor(scratch.stepper, .yellow, .blue)

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

        let isAlive = scratch.stepper.metabolism.tickLifeMath(
            cNeurons: scratch.stepper.net!.cNeurons,
            cOffspring: scratch.stepper.cOffspring
        )

        let canSpawn = scratch.stepper.metabolism.canSpawn

        Grid.arkonsPlaneQueue.async { self.routeLife(isAlive, canSpawn, .arkonsPlane) }
    }
}

extension TickLife {
    private func routeLife(_ isAlive: Bool, _ canSpawn: Bool, _ catchDumbMistakes: DispatchQueueID) {
        assert(catchDumbMistakes == .arkonsPlane)

        Debug.log(level: 167) { "routeLife \(six(scratch.stepper.name))" }

        precondition(Grid.shared.isOnGrid(scratch.stepper.gridCell.gridPosition))

        if !isAlive      { scratch.dispatch!.apoptosize()  }
        else if canSpawn { scratch.dispatch!.spawn()       }
        else             { scratch.dispatch!.computeMove() }
    }
}

extension Metabolism {
    func tickLifeMath(cNeurons: Int, cOffspring: Int) -> Bool {
        let joulesNeeded =

            (capacity * EnergyBudget.joulesCostPerOrganCapacity)
            + (CGFloat(cNeurons) * EnergyBudget.joulesCostPerNeuron)
            + (mass * EnergyBudget.joulesCostPerBodyMass)

        withdrawEnergy(joulesNeeded)

        return ready.level > 0 && lungs.level > 0
    }
}
