import GameplayKit

extension TickState {
    class Start: TickStateBase {
        override func work() -> TickState {
//            print("st: start")
            let fudgeFactor: CGFloat = 1
            let joulesNeeded = fudgeFactor * metabolism.mass

            metabolism.withdrawFromReady(joulesNeeded)

            let oxygenCost: TimeInterval = core.age < TimeInterval(5) ? 0 : 1
            metabolism.oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

            let nextState: TickState = metabolism.fungibleEnergyFullness <= 0 ||
                metabolism.oxygenLevel <= 0 ? .apoptosize : .spawnable

            return nextState
        }
    }
}
