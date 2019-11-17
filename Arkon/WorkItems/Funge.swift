import CoreGraphics
import Foundation

final class Funge: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(flags: .barrier, block: launch_)
    }

    func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    func launch_() {
        let (isAlive, canSpawn) = checkSpawnability()
        fungeRoute(isAlive, canSpawn)
    }
}

extension Funge {
    func fungeRoute(_ isAlive: Bool, _ canSpawn: Bool) {
        guard let (_, dp, _) = scratch?.getKeypoints() else { fatalError() }

        if !isAlive { dp.apoptosize(wiLaunch!); return }
        if !canSpawn { dp.metabolize(wiLaunch!); return }

        dp.wangkhi(wiLaunch!)
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

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
