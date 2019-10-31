import CoreGraphics
import Foundation

extension Metabolism {
    func fungeProper(age: Int, mass: CGFloat) -> Bool {
        print("fungeProper \(mass)")

        let fudgeFactor: CGFloat = 1
        let joulesNeeded = fudgeFactor * mass

        withdrawFromReady(joulesNeeded)

        let oxygenCost: Int = age < 5 ? 0 : 1
        oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}

final class Funge: Dispatchable {

    enum Phase { case checkSpawnability, execute }

    var canSpawn = false
    weak var dispatch: Dispatch!
    var isAlive = false
    var phase = Phase.checkSpawnability
    var stats: World.StatsCopy!
    var stepper: Stepper { return dispatch.stepper }

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
//        print("funge \(dispatch.name.prefix(3)), \(dispatch.stepper?.name.prefix(3) ?? "ftw")")
    }

    func go() { aFunge() }
}

extension Funge {

    func aFunge() {
        switch phase {
        case .checkSpawnability:
            checkSpawnability()

            phase = .execute
            dispatch.callAgain()

        case .execute:
            execute()
        }
    }

    func checkSpawnability() {
        assert(dispatch.runningAsBarrier == true)

        stats = World.stats.copy()

//        print("nasal",
//              dispatch?.name.prefix(3) ?? "wtf6∫",
//              dispatch?.stepper?.name.prefix(3) ?? "wtf146",
//              dispatch?.stepper?.parentStepper?.name.prefix(3) ?? "no parent6 ",
//              dispatch?.stepper?.parentStepper?.dispatch?.name.prefix(3) ?? "no parent6a ",
//              self.dispatch?.name.prefix(3) ?? "wtf6a",
//              self.dispatch?.stepper?.name.prefix(3) ?? "wtf6b; ")

        let age = stats.currentTime - self.stepper.birthday
        let mass = CGFloat(0)// stepper.metabolism.mass
        print("funge \(mass)")

        self.isAlive = stepper.metabolism.fungeProper(age: age, mass: mass)
        self.canSpawn = stepper.canSpawn()
    }

    func execute() {
        if !isAlive {
            dispatch.apoptosize(); return }

        if !canSpawn { dispatch.metabolize() ; return }

        dispatch.wangkhi()
    }
}
