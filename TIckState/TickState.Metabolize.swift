import GameplayKit

extension TickState {
    class MetabolizePending: GKState, TickStateProtocol {
        var statum: TickStatum?
    }

    class Metabolize: GKState, TickStateProtocol {
        var statum: TickStatum?
    }
}

extension TickState.Metabolize {

    override func update(deltaTime seconds: TimeInterval) {
        let barrier = DispatchWorkItemFlags.barrier
        let gq = DispatchQueue.global()
        let qos = DispatchQoS.default

        let metabolizeLeave = DispatchWorkItem(qos: qos, flags: barrier) { [weak self] in
//            print("gmb1", self?.core?.selectoid.fishNumber ?? -1)
            guard let myself = self else { return }
//            print("gmb2", self?.core?.selectoid.fishNumber ?? -1)

            myself.stateMachine?.enter(TickState.Colorize.self)
            myself.stateMachine?.update(deltaTime: 0)
        }

        let metabolizeWork = DispatchWorkItem(qos: qos) { [weak self] in
//            print("fmb1", self?.core?.selectoid.fishNumber ?? -1)
            self?.metabolism?.tick()
            gq.async(execute: metabolizeLeave)
        }

        let metabolizeEnter = DispatchWorkItem(qos: qos, flags: barrier) { [weak self] in
//            print("emb1", self.core?.selectoid.fishNumber ?? -1)
            self?.stateMachine?.enter(TickState.MetabolizePending.self)
            self?.stateMachine?.update(deltaTime: 0)
            gq.async(execute: metabolizeWork)
        }

        gq.async(execute: metabolizeEnter)
    }
}
