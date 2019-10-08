import SpriteKit

extension TickState {
    class Spawnable: TickStateBase {
        override func work() -> TickState {
//            print("st: spawnable")
            let entropy = 0.1
            let spawnCost = EnergyReserve.startingEnergyLevel * CGFloat(1.0 + entropy)

            if metabolism.spawnReserves.level >= spawnCost {
                metabolism.withdrawFromSpawn(spawnCost)

                let activator = core.net.activatorFunction
                let biases = core.net.biases
                let weights = core.net.weights
                let layers = core.net.layers

                let waitAction = SKAction.run {}// SKAction.wait(forDuration: 0.02)
                let spawnAction = SKAction.run { [weak self] in
                    let offspring = Stepper.spawn(
                        parentBiases: biases, parentWeights: weights,
                        layers: layers, parentActivator: activator,
                        parentPosition: self?.stepper?.gridlet.gridPosition ?? AKPoint.zero
                    )

                    offspring.tickStatum?.statumLaunch()
                }

                let postscript = SKAction.run { [weak self] in
                    guard let myself = self else { fatalError() }
                    myself.core.selectoid.cOffspring += 1
                    World.shared.registerCOffspring(myself.core.selectoid.cOffspring)
                    self?.statum?.statumLeave(to: .metabolize)
                }

                statum?.action = SKAction.sequence([waitAction, spawnAction, postscript])
                statum?.actioner = Arkon.arkonsPortal
                return .nop
            }

            return .metabolize
        }
    }
}
