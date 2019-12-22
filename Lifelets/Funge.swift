import CoreGraphics
import Foundation

final class Funge: Dispatchable {
    override func launch() {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }
        debugColor(st, .yellow, .yellow)
        let (isAlive, canSpawn) = checkSpawnability()
        fungeRoute(isAlive, canSpawn)
    }
}

extension Funge {
    func fungeRoute(_ isAlive: Bool, _ canSpawn: Bool) {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        precondition(
            (ch.engagerKey == nil  ||
                (ch.engagerKey?.sprite?.getStepper(require: false)?.name == st.name &&
                ch.engagerKey?.gridPosition == st.gridCell.gridPosition &&
                ch.engagerKey?.sprite?.getStepper(require: false)?.gridCell.gridPosition == st.gridCell.gridPosition)
        ))

        if !isAlive  { dp.apoptosize(); return }
        if !canSpawn { dp.plot(); return }

        dp.spawn()
    }
}

extension Funge {
    func checkSpawnability() -> (Bool, Bool) {
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }
        guard let ws = ch.worldStats else { fatalError() }

        let age = st.getAge(ws.currentTime)

        let isAlive = st.metabolism.fungeProper(age: age, stillCounter: ch.stillCounter)
        let canSpawn = st.canSpawn()

        return (isAlive, canSpawn)
    }
}

extension Metabolism {
    func fungeProper(age: Int, stillCounter: CGFloat) -> Bool {
        let fudgeMassFactor: CGFloat = 10
        let joulesNeeded = fudgeMassFactor * mass

        withdrawFromReady(joulesNeeded)

        let gracePeriodFactor: CGFloat = (age < 5 ? 0 : 1)
        let oxygenCost: CGFloat = 0.005 * gracePeriodFactor
        let ratchet: CGFloat = 1.0 //CGFloat(1 + Int(stillCounter * 100) / 5)
        let stillnessCost: CGFloat = (pow(1.01, stillCounter) - 1) * gracePeriodFactor * ratchet

        oxygenLevel -= oxygenCost + stillnessCost

        if stillnessCost > 0 {
            Log.L.write(
                "\nfungeProper:" +
                " mass = \(String(format: "%-2.6f", mass)), withdraw \(String(format: "%-2.6f", joulesNeeded))" +
                " stillnessCounter = \(stillCounter)" +
                " oxygenLevel = \(String(format: "%-3.2f%%", oxygenLevel * 100))" +
                " oxygenCost = \(String(format: "%-2.6f", oxygenCost))" +
                " stillnessCost = \(String(format: "%-2.6f", stillnessCost))" +
                " f.EnergyFullness = \(String(format: "%-3.2f%%", fungibleEnergyFullness * 100))" +
                " ...Capacity =  \(String(format: "%-2.6f", fungibleEnergyCapacity))" +
                " ...Content =  \(String(format: "%-2.6f", fungibleEnergyContent))"
                , level: 61
            )
        }

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
