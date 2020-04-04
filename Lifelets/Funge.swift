import CoreGraphics
import Foundation

final class Funge: Dispatchable {

    static let dispatchQueue = DispatchQueue(
        label: "ak.funge.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .default)
    )

    override func launch() {
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log(level: 156) { "Funge \(six(st.name))" }
        Debug.debugColor(st, .yellow, .blue)
        guard let ek = ch.engagerKey as? HotKey else { fatalError() }

        Funge.TickLife(st).tick { self.fungeRoute($0, $1, ek) }
    }
}

extension Funge {
    func fungeRoute(_ isAlive: Bool, _ canSpawn: Bool, _ hotKey: HotKey) {
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }
        precondition(Grid.shared.isOnGrid(st.gridCell.gridPosition))

        Debug.log(level: 104) { "fungeRoute for \(six(st.name)) at \(st.gridCell.gridPosition) isAlive \(isAlive) canSpawn \(canSpawn)" }

        if !isAlive {
            hotKey.releaseLock()
            dp.apoptosize()
            return
        }

        if !canSpawn || Census.shared.population > Arkonia.maxPopulation { dp.computeMove(); return }

        dp.spawn()
    }
}

extension Metabolism {

    func fungeProper(
        cNeurons: Int, co2Counter: CGFloat, cOffspring: Int, currentTime: Int
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
