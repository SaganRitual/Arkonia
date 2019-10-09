import SpriteKit

extension Stepper {
    func cspawn() {
//        print("st: spawnable")

        let entropy = 0.1
        let spawnCost = EnergyReserve.startingEnergyLevel * CGFloat(1.0 + entropy)

        if metabolism.spawnReserves.level >= spawnCost {
            metabolism.withdrawFromSpawn(spawnCost)

            let activator = core.net.activatorFunction
            let biases = core.net.biases
            let weights = core.net.weights
            let layers = core.net.layers

            let waitAction = SKAction.run {}// SKAction.wait(forDuration: 0.02)
            let spawnAction = SKAction.run { [unowned self] in
                let offspring = Stepper.spawn(
                    parentBiases: biases, parentWeights: weights,
                    layers: layers, parentActivator: activator,
                    parentPosition: self.gridlet.gridPosition
                )

                offspring.coordinator.dispatch(.actionComplete_spawn)
            }

            let sequence = SKAction.sequence([waitAction, spawnAction])

            Arkon.arkonsPortal?.run(sequence) { [unowned self] in
                self.core.selectoid.cOffspring += 1
                World.shared.registerCOffspring(self.core.selectoid.cOffspring)
                self.coordinator.dispatch(.actionComplete_cspawn)
            }

            return
        }

        self.coordinator.dispatch(.actionComplete_cspawn)
    }
}
