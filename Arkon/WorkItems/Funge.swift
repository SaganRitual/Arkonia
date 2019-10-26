import CoreGraphics
import Foundation

extension Stepper {
    func funge() {
//        print("funge \(name)")
        World.stats.getTimeSince(birthday, relay)
    }

    func relay(_ age: Int) {
//        print("relay_ \(name)")
        metabolism.funge(self, age: age)
    }
}

extension Metabolism {

    func funge(_ parentStepper: Stepper?, age: Int) {

        World.lock({ () -> [Bool]? in

            let isAlive = self.funge_(age: age)
            return [isAlive]

        }, { (_ isAlives: [Bool]?) in

            guard let isAlive = isAlives?[0] else { fatalError() }
            guard let ps = parentStepper else { fatalError() }

            if !isAlive {
//                print("dead? \(parentStepper!.name)")
                ps.apoptosize(); return }

            if !ps.canSpawn() {
//                print("can't spawn \(parentStepper!.name)")
                ps.metabolize(); return }

//            print("spawning from \(parentStepper!.name)")
            ps.spawnCommoner()
        },
           .concurrent
        )
    }

    private func funge_(age: Int) -> Bool {
//        print("funge_")
        let fudgeFactor: CGFloat = 1
        let joulesNeeded = fudgeFactor * mass_

        withdrawFromReady(joulesNeeded)

        let oxygenCost: Int = age < 5 ? 0 : 1
        oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
