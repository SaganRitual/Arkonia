import CoreGraphics
import Foundation

typealias LockBool = Dispatch.Lockable<Bool>

extension Metabolism {

    func funge(
        _ age: TimeInterval,
        alive: @escaping () -> Void,
        dead: @escaping () -> Void
    ) {
        print("dl funge")
        Catchall.lock({ () -> [Bool]? in
            let isAlive = self.funge_(age: age)
            return [isAlive]
        }, {
            guard let isAlive = $0?[0] else { fatalError() }
            if isAlive {
                print("dl alive")
                alive() } else {
                print("dl dead")
                dead() }
        },
           .continueBarrier
        )
    }

    private func funge_(age: TimeInterval) -> Bool {
        let fudgeFactor: CGFloat = 1
        let joulesNeeded = fudgeFactor * mass

        withdrawFromReady(joulesNeeded)

        let oxygenCost: TimeInterval = age < TimeInterval(5) ? 0 : 1
        oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

        return fungibleEnergyFullness > 0 && oxygenLevel > 0
    }
}
