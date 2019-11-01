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

    enum Phase { case getWorldStats, checkSpawnability, execute }

    var canSpawn = false
    weak var dispatch: Dispatch!
    var isAlive = false
    var phase = Phase.getWorldStats
    var runAsBarrier = true
    var stats: World.StatsCopy!
    var stepper: Stepper { return dispatch.stepper }

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
    }

    func go() { aFunge() }
}

extension Funge {

    func aFunge() {
        switch phase {
        case .getWorldStats:
            getWorldStats()
            callAgain(.checkSpawnability, false)

        case .checkSpawnability:
            checkSpawnability()
            callAgain(.execute, false)

        case .execute:
            execute()
        }
    }

    func callAgain(_ phase: Phase, _ runAsBarrier: Bool) {
        self.phase = phase
        self.runAsBarrier = runAsBarrier
        dispatch.callAgain()
    }

    func getWorldStats() {
        stats = World.stats.copy()
    }

    func checkSpawnability() {
        let age = stats.currentTime - self.stepper.birthday
        let mass = stepper.metabolism.mass

        self.isAlive = stepper.metabolism.fungeProper(age: age, mass: mass)
        self.canSpawn = stepper.canSpawn()
    }

    func execute() {
        if !isAlive { dispatch.apoptosize(); return }

        if !canSpawn { dispatch.metabolize() ; return }

        dispatch.wangkhi()
    }
}
