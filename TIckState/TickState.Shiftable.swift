import GameplayKit

extension TickState {
    class Shiftable: GKState, TickStateProtocol {
        var statum: TickStatum?
    }

    class ShiftablePending: GKState, TickStateProtocol {
        var statum: TickStatum?
    }
}

extension TickState.Shiftable {

    override func update(deltaTime seconds: TimeInterval) {
        let barrier = DispatchWorkItemFlags.barrier
        let gq = DispatchQueue.global()
        let qos = DispatchQoS.default
        var shiftable = false

        let shiftableLeave = DispatchWorkItem(qos: qos, flags: barrier) { [weak self] in
//            print("ghl1", self?.core?.selectoid.fishNumber ?? -1)
            guard let myself = self else { return }
//            print("ghl2", self?.core?.selectoid.fishNumber ?? -1)

            myself.stateMachine?.enter(
                shiftable ? TickState.Shift.self : TickState.Start.self
            )

            myself.stateMachine?.update(deltaTime: 0)
        }

        let shiftableWork = DispatchWorkItem(qos: qos, flags: barrier) { [weak self] in
//            print("fhl1", self?.core?.selectoid.fishNumber ?? -1)
            guard let myself = self else { return }
//            print("fhl2", self?.core?.selectoid.fishNumber ?? -1)
            shiftable = myself.calculateShift()
            gq.async(execute: shiftableLeave)
        }

        let shiftableEnter = DispatchWorkItem(qos: qos, flags: barrier) { [weak self] in
//            print("ehl", self.core?.selectoid.fishNumber ?? -1)
            self?.stateMachine?.enter(TickState.ShiftablePending.self)
            self?.stateMachine?.update(deltaTime: 0)
            gq.async(execute: shiftableWork)
        }

        gq.async(execute: shiftableEnter)
    }

    func calculateShift() -> Bool {
        guard let s = self.stepper else { return false }
        let senseData = s.loadSenseData()
        statum?.shiftTarget = s.selectMoveTarget(senseData)

        return (statum?.shiftTarget ?? AKPoint.zero) != AKPoint.zero
    }
}
