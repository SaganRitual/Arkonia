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
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log(level: 156) { "TickLife \(six(st.name))" }
        Debug.debugColor(st, .yellow, .blue)

        tick()
    }

    private func tick() { Clock.dispatchQueue.async(execute: tickLife_) }
}

extension TickLife {
    private func tickLife() {
        guard let (ch, _, _) = scratch?.getKeypoints() else { fatalError() }

        ch.currentTime = Clock.shared!.worldClock
        ch.currentEntropyPerJoule = Double(1 - Clock.shared!.getEntropy())

        TickLife.dispatchQueue.async(execute: tickLife_)
    }

    private func tickLife_() {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        let isAlive = st.metabolism.tickLifeMath(
            cNeurons: st.net!.cNeurons,
            co2Counter: st.dispatch.scratch.co2Counter,
            cOffspring: st.cOffspring
        )

        let canSpawn = st.canSpawn()

        routeLife(isAlive, canSpawn)
    }
}

extension TickLife {
    private func routeLife(_ isAlive: Bool, _ canSpawn: Bool) {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let hotKey = ch.engagerKey as? HotKey else { fatalError() }

        precondition(Grid.shared.isOnGrid(st.gridCell.gridPosition))

        Debug.log(level: 104) { "tickLifeRoute for \(six(st.name)) at \(st.gridCell.gridPosition) isAlive \(isAlive) canSpawn \(canSpawn)" }

        if !isAlive {
            hotKey.releaseLock()
            dp.apoptosize()
            return
        }

        if canSpawn { dp.spawn() } else { dp.computeMove() }
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
