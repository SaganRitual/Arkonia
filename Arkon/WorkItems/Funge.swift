import CoreGraphics
import Foundation

final class Funge: Dispatchable {
    internal override func launch_() {
        let (isAlive, canSpawn) = checkSpawnability()
        fungeRoute(isAlive, canSpawn)
    }
}

extension Funge {
    func fungeRoute(_ isAlive: Bool, _ canSpawn: Bool) {
        guard let (_, dp, _) = scratch?.getKeypoints() else { fatalError() }

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

        let isAlive = st.metabolism.fungeProper(age: age)
        let canSpawn = st.canSpawn()

        return (isAlive, canSpawn)
    }
}

extension Metabolism {
    func fungeProper(age: Int) -> Bool {
        let fudgeMassFactor: CGFloat = 1
        let joulesNeeded = fudgeMassFactor * mass

        withdrawFromReady(joulesNeeded)

        let fudgeOxygenFactor: CGFloat = 30
        let oxygenCost: Int = age < 1 ? 0 : 1
        oxygenLevel -= (CGFloat(oxygenCost) / fudgeOxygenFactor)

        Log.L.write(
            "fungeProper:" +
            " mass = \(String(format: "%-2.6f", mass)), withdraw \(String(format: "%-2.6f", joulesNeeded))" +
//            " fungibleEnergyCapacity =  \(String(format: "%-2.6f", fungibleEnergyCapacity))" +
//            " fungibleEnergyContent =  \(String(format: "%-2.6f", fungibleEnergyContent))" +
            " fungibleEnergyFullness = \(String(format: "%-3.2f%%", fungibleEnergyFullness * 100))" +
            " oxygenLevel = \(String(format: "%-3.2f%%", oxygenLevel * 100))"
            , level: 35
        )

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
