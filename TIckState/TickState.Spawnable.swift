import GameplayKit

extension TickState {
    class Spawnable: GKState, TickStateProtocol {
        var statum: TickStatum?
    }

    class SpawnablePending: GKState, TickStateProtocol {
        var statum: TickStatum?
    }
}

extension TickState.Spawnable {

    override func update(deltaTime seconds: TimeInterval) {
        var alive = true
        let barrier = DispatchWorkItemFlags.barrier
        let gq = DispatchQueue.global()
        let qos = DispatchQoS.default

        let spawnableLeave = DispatchWorkItem(qos: qos) { [weak self] in
            defer {
//                print("gsl3", alive, self?.core?.selectoid.fishNumber ?? -1)
                self?.stateMachine?.enter(TickState.Metabolize.self)
                self?.stateMachine?.update(deltaTime: 0)
            }

//            print("gsl1", alive, self?.core?.selectoid.fishNumber ?? -1)
            if self == nil || alive == false { return }
//            print("gsl2", alive, self?.core?.selectoid.fishNumber ?? -1)
        }

        let spawnableWork = DispatchWorkItem(qos: qos) { [weak self] in
//            print("fsl1", alive, self?.core?.selectoid.fishNumber ?? -1)
            guard let myself = self, alive == true else { return }
//            print("fsl2", alive, myself.core?.selectoid.fishNumber ?? -1)

            alive = myself.attemptSpawn(alive)
            gq.async(execute: spawnableLeave)
        }

        let spawnableEnter = DispatchWorkItem(qos: qos, flags: barrier) { [weak self] in
            guard let myself = self else { return }

//            print("esl", alive, myself.core?.selectoid.fishNumber ?? -1)
            myself.stateMachine?.enter(TickState.SpawnablePending.self)
            gq.async(execute: spawnableWork)
        }

        gq.async(execute: spawnableEnter)
    }

    func attemptSpawn(_ isAlive: Bool) -> Bool {
        guard let mb = metabolism else { return false }
        guard let cr = core else { return false }

        let entropy = 0.1
        let spawnCost = EnergyReserve.startingEnergyLevel * CGFloat(1.0 + entropy)

        if mb.spawnReserves.level >= spawnCost {
            mb.withdrawFromSpawn(spawnCost)

            let activator = cr.net.activatorFunction
            let biases = cr.net.biases
            let weights = cr.net.weights
            let layers = cr.net.layers
            let waitAction = SKAction.run {}// SKAction.wait(forDuration: 0.02)
            let spawnAction = SKAction.run { [weak self] in
                Stepper.spawn(
                    parentBiases: biases, parentWeights: weights,
                    layers: layers, parentActivator: activator,
                    parentPosition: self?.stepper?.gridlet.gridPosition ?? AKPoint.zero
                )
            }

            let sequence = SKAction.sequence([waitAction, spawnAction])
            Arkon.arkonsPortal!.run(sequence) {
                cr.selectoid.cOffspring += 1
                World.shared.registerCOffspring(cr.selectoid.cOffspring)
            }

        }

        return true
    }
}
