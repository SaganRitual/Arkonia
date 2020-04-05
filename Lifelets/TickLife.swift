import CoreGraphics
import Foundation

final class TickLife: Dispatchable {
    var isAlive = false
    var canSpawn = false
    var onComplete: ((Bool, Bool) -> Void)?

    static let dispatchQueue = DispatchQueue(
        label: "ak.ticklife.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .default)
    )

    override func launch() {
        Debug.log(level: 156) { "TickLife \(six(scratch.stepper.name))" }
        Debug.debugColor(scratch.stepper, .yellow, .blue)

        tick()
    }

    private func tick() { Clock.dispatchQueue.async(execute: tickLife_) }
}

extension TickLife {
    private func tickLife() {
        scratch.currentTime = Clock.shared!.worldClock
        scratch.currentEntropyPerJoule = Double(1 - Clock.shared!.getEntropy())

        TickLife.dispatchQueue.async(execute: tickLife_)
    }

    private func tickLife_() {
        let isAlive = scratch.stepper.metabolism.tickLifeMath(
            cNeurons: scratch.stepper.net!.cNeurons,
            co2Counter: scratch.stepper.dispatch.scratch.co2Counter,
            cOffspring: scratch.stepper.cOffspring
        )

        let canSpawn = scratch.stepper.canSpawn()

        routeLife(isAlive, canSpawn)
    }
}

extension TickLife {
    private func routeLife(_ isAlive: Bool, _ canSpawn: Bool) {
        guard let hotKey = scratch.engagerKey as? HotKey else { fatalError() }

        precondition(Grid.shared.isOnGrid(scratch.stepper.gridCell.gridPosition))

        if !isAlive {
            hotKey.releaseLock()
            scratch.dispatch!.apoptosize()
            return
        }

        if canSpawn { scratch.dispatch!.spawn() } else { scratch.dispatch!.computeMove() }
    }
}

extension Metabolism {
    func tickLifeMath(
        cNeurons: Int, co2Counter: CGFloat, cOffspring: Int
    ) -> Bool {
        let joulesNeeded = Arkonia.fudgeMassFactor * mass + CGFloat(cNeurons) * Arkonia.neuronCostPerCycle

        withdrawFromReady(joulesNeeded)

        let oxygenCost: CGFloat = Arkonia.oxygenCostPerTick
        let co2Cost: CGFloat = pow(Arkonia.co2BaseCost, co2Counter)

        Debug.log(level: 96) { "O2 cost \(oxygenCost), CO2 cost \(co2Cost)" }

        oxygenLevel -= oxygenCost
        co2Level += co2Cost

        Debug.log(level: 96) { "O2 level \(oxygenLevel), CO2 level \(co2Level)" }

        return
            fungibleEnergyFullness > 0 &&
            oxygenLevel > 0 &&
            co2Level < Arkonia.co2MaxLevel
    }
}
