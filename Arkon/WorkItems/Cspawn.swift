import SpriteKit

extension Stepper {
    func cspawn(
        goParent: @escaping StepperSimpleCallback,
        goOffspring: @escaping StepperSimpleCallback
    ) {
        let entropy = 0.1
        let spawnCost = EnergyReserve.startingEnergyLevel * CGFloat(1.0 + entropy)

        if metabolism.spawnReserves.level >= spawnCost {
            metabolism.withdrawFromSpawn(spawnCost)

            let activator = core.net.activatorFunction
            let biases = core.net.biases
            let weights = core.net.weights
            let layers = core.net.layers

            var offspring: Stepper?
            let waitAction = SKAction.run {}// SKAction.wait(forDuration: 0.02)
            let spawnAction = SKAction.run { [unowned self] in
                assert(Display.displayCycle == .actions)
                offspring = Stepper.spawn(
                    parentBiases: biases, parentWeights: weights,
                    layers: layers, parentActivator: activator,
                    parentPosition: self.gridlet.gridPosition
                )

                assert(Display.displayCycle == .actions)
                self.core.selectoid.cOffspring += 1
                World.shared.registerCOffspring(self.core.selectoid.cOffspring)
            }

            let sequence = SKAction.sequence([waitAction, spawnAction])

            sprite.run(sequence) { [unowned self] in
                goParent(self)
                goOffspring(offspring!)
                offspring!.stepperIsEngaged = false
            }

            return
        }

        let nothing = SKAction.run {}
        sprite.run(nothing) { [weak self] in
            guard let myself = self else { return }
            goParent(myself)
        }
    }
}
