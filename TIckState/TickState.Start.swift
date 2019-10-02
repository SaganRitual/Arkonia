import GameplayKit

extension TickState {
    class Start: GKState, TickStateProtocol {
        var statum: TickStatum?

        var alive = false
        let barrier = DispatchWorkItemFlags.barrier
        let gq = DispatchQueue.global()
        let qos = DispatchQoS.default
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

        let fungeLeave = DispatchWorkItem(qos: qos, flags: barrier) { [weak self] in
            guard let myself = self else { assert(false) }

            print("gfs", myself.alive, myself.core?.selectoid.fishNumber ?? -1)
            myself.stateMachine?.enter(
                myself.alive ? TickState.Spawnable.self : TickState.Apoptosize.self
            )

            myself.stateMachine?.update(deltaTime: 0)
        }

        let fungeWork = DispatchWorkItem(qos: qos) { [weak self] in
            print("ffs1", self?.alive ?? false, self?.core?.selectoid.fishNumber ?? -1)

            guard let myself = self else { assert(false) }
            guard let mb = myself.metabolism else { assert(false) }
            guard let cr = myself.core else { assert(false) }

            print("ffs2", myself.alive, myself.core?.selectoid.fishNumber ?? -1)

            let fudgeFactor: CGFloat = 1
            let joulesNeeded = fudgeFactor * mb.mass

            mb.withdrawFromReady(joulesNeeded)

            let oxygenCost: TimeInterval = cr.age < TimeInterval(5) ? 0 : 1
            mb.oxygenLevel -= (CGFloat(oxygenCost) / 60.0)

            myself.alive = mb.fungibleEnergyFullness > 0 && mb.oxygenLevel > 0

            myself.gq.async(execute: fungeLeave)
        }

        let fungeEnter = DispatchWorkItem(qos: qos, flags: barrier) { [weak self] in
            print("efs1", self?.alive ?? false, self?.core?.selectoid.fishNumber ?? -1)
            guard let myself = self else { assert(false) }
            myself.stateMachine?.enter(TickState.StartPending.self)
            myself.stateMachine?.update(deltaTime: 0)
            print("efs2", myself.alive, myself.core?.selectoid.fishNumber ?? -1)
            myself.gq.async(execute: fungeWork)
        }

        DispatchQueue.global().async(execute: fungeEnter)
    }
}
