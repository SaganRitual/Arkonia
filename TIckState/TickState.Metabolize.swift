import GameplayKit

extension TickState {
    class Metabolize: TickStateBase {
        override func work() -> TickState {
//            print("st: metabolize")
            metabolism.tick()
            return .colorize
        }
    }
}
