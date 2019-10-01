import GameplayKit

extension TickState {
    class Start: GKState, TickStateProtocol {
        var statum: TickStatum?
    }

    class StartPending: GKState, TickStateProtocol {
        var statum: TickStatum?
    }
}

extension TickState.StartPending {

    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        assert(stateClass == TickState.Apoptosize.self &&
                stateClass == TickState.Spawnable.self)

        return true
    }
}

extension TickState.Start {

    override func update(deltaTime seconds: TimeInterval) {

        var alive = false
        let barrier = DispatchWorkItemFlags.barrier
        let gq = DispatchQueue.global()
        let qos = DispatchQoS.default

        let fungeLeave = DispatchWorkItem(qos: qos) { [weak self] in
            guard let myself = self else { return }

//            print("gfs", alive, self?.core?.selectoid.fishNumber ?? -1)
            myself.stateMachine?.enter(
                alive ? TickState.Spawnable.self : TickState.Apoptosize.self
            )

            myself.stateMachine?.update(deltaTime: 0)
        }

        let fungeWork = DispatchWorkItem(qos: qos) { [weak self] in
//            print("ffs1", alive, self?.stateMachine?.currentState ?? GKState.Type.self, self?.core?.selectoid.fishNumber ?? -1)

            guard let myself = self else { return }
            guard let mb = myself.metabolism else { return }
            guard let cr = myself.core else { return }

//            print("ffs2", alive, self?.core?.selectoid.fishNumber ?? -1)

            let fudgeFactor: CGFloat = 1
            let joulesNeeded = fudgeFactor * mb.mass

            mb.withdrawFromReady(joulesNeeded)

            let oxygenCost: TimeInterval = cr.age < TimeInterval(5) ? 0 : 1
            mb.oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

            alive = mb.fungibleEnergyFullness > 0 && mb.oxygenLevel > 0

            gq.async(execute: fungeLeave)
        }

        let fungeEnter = DispatchWorkItem(qos: qos, flags: barrier) { [weak self] in
//            print("efs1", alive, self?.core?.selectoid.fishNumber ?? -1)
            self?.stateMachine?.enter(TickState.StartPending.self)
//            print("efs2", self?.stateMachine?.currentState ?? GKState.Type.self, alive, self?.core?.selectoid.fishNumber ?? -1)
            gq.async(execute: fungeWork)
        }

        DispatchQueue.global().async(execute: fungeEnter)
    }
}
