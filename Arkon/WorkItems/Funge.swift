import CoreGraphics
import Foundation

final class Funge: Dispatchable {
    override func launch() {
        guard let w = wiLaunch else { fatalError() }
        World.shared.concurrentQueue.async(execute: w)
    }

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

        if ch.stillCounter > 0 { Log.L.write("stillnessCost \(ch.stillCounter)", level: 46) }
        let isAlive = st.metabolism.fungeProper(age: age, stillnessCost: CGFloat(ch.stillCounter))
        let canSpawn = st.canSpawn()

        return (isAlive, canSpawn)
    }
}

extension Metabolism {
    func fungeProper(age: Int, stillnessCost: CGFloat) -> Bool {
        let fudgeMassFactor: CGFloat = 10
        let joulesNeeded = fudgeMassFactor * mass

        withdrawFromReady(joulesNeeded)

        let fudgeOxygenFactor: CGFloat = 30
        let oxygenCost: Int = age < 1 ? 0 : 1
        oxygenLevel -= CGFloat(oxygenCost) * (1 + stillnessCost) / fudgeOxygenFactor

        if stillnessCost > 0 {
            Log.L.write(
                "\nfungeProper:" +
                " mass = \(String(format: "%-2.6f", mass)), withdraw \(String(format: "%-2.6f", joulesNeeded))" +
                " fungibleEnergyFullness = \(String(format: "%-3.2f%%", fungibleEnergyFullness * 100))" +
                " oxygenLevel = \(String(format: "%-3.2f%%", oxygenLevel * 100))" +
                " fungibleEnergyCapacity =  \(String(format: "%-2.6f", fungibleEnergyCapacity))" +
                " fungibleEnergyContent =  \(String(format: "%-2.6f", fungibleEnergyContent))" +
                " stillnessCost = \(String(format: "%-2.6f", stillnessCost))"
                , level: 46
            )
        }

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
