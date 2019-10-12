import CoreGraphics
import Foundation

extension Metabolism {
    func funge(
        _ age: TimeInterval, alive: @escaping CoordinatorCallback,
        dead: @escaping CoordinatorCallback
    ) {
//        syncQueue.async(flags: .barrier) { [unowned self] in
            self.funge_(age, alive: alive, dead: dead)
//        }
    }

    private func funge_(
        _ age: TimeInterval, alive: CoordinatorCallback, dead: CoordinatorCallback
    ) {
        let fudgeFactor: CGFloat = 1
        let joulesNeeded = fudgeFactor * mass

        withdrawFromReady(joulesNeeded)

        let oxygenCost: TimeInterval = age < TimeInterval(5) ? 0 : 1
        oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

        if fungibleEnergyFullness > 0 && oxygenLevel > 0 { alive() }
        else { dead() }
    }
}
