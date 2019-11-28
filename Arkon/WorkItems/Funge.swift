import CoreGraphics
import Foundation

final class Funge: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Funge()", level: 3)
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    func launch_() {
        Log.L.write("Funge.launch_ \(six(scratch?.stepper?.name))", level: 15)
        let (isAlive, canSpawn) = checkSpawnability()
        fungeRoute(isAlive, canSpawn)
    }
}

extension Funge {
    func fungeRoute(_ isAlive: Bool, _ canSpawn: Bool) {
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Log.L.write("fungeroute \(six(st.name))", level: 15)

        if !isAlive {
            Log.L.write("fungeroute apop \(six(st.name))", level: 15)
            dp.apoptosize(); return }
        if !canSpawn {
            Log.L.write("fungeroute plot \(six(st.name))", level: 15)
            dp.plot(); return }

        Log.L.write("fungeroute wangkhi \(six(st.name))", level: 15)
        dp.wangkhi()
    }
}

extension Funge {
    func checkSpawnability() -> (Bool, Bool) {
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }
        guard let ws = ch.worldStats else { fatalError() }

        let age = ws.currentTime - st.birthday

        let isAlive = st.metabolism.fungeProper(age: age)
        let canSpawn = st.canSpawn()

        return (isAlive, canSpawn)
    }
}

extension Metabolism {
    func fungeProper(age: Int) -> Bool {
        let fudgeFactor: CGFloat = 1
        let joulesNeeded = fudgeFactor * mass

        withdrawFromReady(joulesNeeded)

        let oxygenCost: Int = age < 5 ? 0 : 1
        oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

        Log.L.write(
            "fungeProper:" +
            " mass = \(mass), withdraw \(joulesNeeded)" +
            " fungibleEnergyCapacity =  \(String(format: "%-2.6f", fungibleEnergyCapacity))" +
            " fungibleEnergyContent =  \(String(format: "%-2.6f", fungibleEnergyContent))" +
            " fungibleEnergyFullness = \(String(format: "%-2.6f", fungibleEnergyFullness * 100))" +
            " oxygenLevel = \(String(format: "%-2.6f", oxygenLevel * 100))"
            , level: 13
        )

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
