import CoreGraphics
import Foundation

extension Metabolism {
    func fungeProper(age: Int, mass: CGFloat) -> Bool {

        let fudgeFactor: CGFloat = 1
        let joulesNeeded = fudgeFactor * mass

        withdrawFromReady(joulesNeeded)

        let oxygenCost: Int = age < 5 ? 0 : 1
        oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}

final class Funge: Dispatchable {
    weak var dispatch: Dispatch!
    var stats: World.StatsCopy!
    var stepper: Stepper { return dispatch.stepper }

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
    }

    func go() { aFunge() }
}

extension Funge {

    func aFunge() {
        assert(dispatch.runningAsBarrier == true)

        stats = World.stats.copy()

        let age = stats.currentTime - self.stepper.birthday
        let mass = stepper.metabolism.mass
        let isAlive = stepper.metabolism.fungeProper(age: age, mass: mass)
        let canSpawn = stepper.canSpawn()

        dispatch.go({ self.bFunge(isAlive, canSpawn) }, runAsBarrier: false)
    }

    func bFunge(_ isAlive: Bool, _ canSpawn: Bool) {
        if !isAlive { dispatch.apoptosize(); return }

        if !canSpawn { dispatch.metabolize() ; return }

        dispatch.wangkhi()
    }
}
