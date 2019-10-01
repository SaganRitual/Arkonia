import GameplayKit

extension TickState {
    class Apoptosize: GKState, TickStateProtocol {
        var statum: TickStatum?
    }

    class ApoptosizePending: GKState, TickStateProtocol {
        var statum: TickStatum?
    }
}

extension TickState.ApoptosizePending {
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        assert(stateClass == TickState.Dead.self)
        return true
    }
}

extension TickState.Apoptosize {

    func apoptosize() {
        guard let stepper = self.stepper else { return }
        guard let sprite = stepper.sprite else { return }

        let action = SKAction.run { [weak self] in
            guard let cr = self?.core else { return }
            guard let st = self?.stateMachine else { return }

            cr.apoptosize()
            st.enter(TickState.Dead.self)
        }

        sprite.run(action)
    }

    override func didEnter(from previousState: GKState?) {
        stateMachine?.enter(TickState.ApoptosizePending.self)
        apoptosize()
    }
}
