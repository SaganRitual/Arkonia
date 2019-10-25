import CoreGraphics
import Foundation

extension Stepper {
    func funge() {
//        print("funge \(name)")
        World.lock(getAge_, relay_, .concurrent)
    }

    func getAge_() -> [TimeInterval]? {
//        print("getAge \(name)")
        let age = World.shared.getCurrentTime_() - birthday
        return [age]
    }

    func relay_(_ ages: [TimeInterval]?) {
//        print("relay_ \(name)")
        guard let age = ages?[0] else { fatalError() }
        metabolism.funge(self, age: age)
    }
}

extension Metabolism {

    func funge(_ parentStepper: Stepper?, age: TimeInterval) {

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

    private func funge_(age: TimeInterval) -> Bool {
//        print("funge_")
        let fudgeFactor: CGFloat = 1
        let joulesNeeded = fudgeFactor * mass

        withdrawFromReady(joulesNeeded)

        let oxygenCost: TimeInterval = age < TimeInterval(5) ? 0 : 1
        oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
