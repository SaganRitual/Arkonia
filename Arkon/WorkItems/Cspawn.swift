import SpriteKit

struct CSpawn {
    let goOffspring: StepperSimpleCallback?
    let goParent: StepperSimpleCallback?
    weak var stepper: Stepper?

    init(
        _ stepper: Stepper?,
        goParent: StepperSimpleCallback? = nil,
        goOffspring: StepperSimpleCallback? = nil
    ) {
        self.stepper = stepper
        self.goOffspring = goOffspring
        self.goParent = goParent
    }

    func spawnProgenitor() {
        Grid.getRandomPoint(background: Arkon.arkonsPortal!) { rp in
            self.makeStepper_(at: rp)
        }
    }

    let allowSpawning = true

    func spawnIf() {
        guard let st = stepper else { fatalError() }

        let entropy: CGFloat = 0.1
        let spawnCost: CGFloat

        if allowSpawning {
            spawnCost = EnergyReserve.startingEnergyLevel * CGFloat(1.0 + entropy)
        } else {
            spawnCost = CGFloat.infinity
        }

        if st.metabolism.spawnReserves.level < spawnCost {
            goParent!(st)
            return
        }

        st.metabolism.withdrawFromSpawn(spawnCost)

        asyncQueue.async { self.setOffspringPosition() }
    }

    private func getGridPointNearParent() -> Grid.RandomGridPoint? {

        guard let st = stepper else { return nil }

        for offset in Stepper.gridInputs {
            let offspringPosition = st.gridlet.gridPosition + offset

            if Gridlet.isOnGrid(offspringPosition.x, offspringPosition.y) {
                let gridlet = Gridlet.at(offspringPosition)
                if gridlet.contents == .nothing {
                    return Grid.RandomGridPoint(gridlet: gridlet, cgPoint: gridlet.scenePosition)
                }
            }
        }

        return nil
    }

    private func makeStepper_(at randomPoint: Grid.RandomGridPoint) {
        let newCore = Arkon(
            parentBiases: stepper?.core.net.biases,
            parentWeights: stepper?.core.net.weights,
            layers: stepper?.core.net.layers,
            parentActivator: stepper?.core.net.activatorFunction
        )

        let newMetabolism = Metabolism(core: newCore)

        newCore.sprite.color = .cyan
        newCore.sprite.color = .cyan
        newCore.sprite.setScale(0.5)
        newCore.sprite.position = randomPoint.cgPoint
        newCore.sprite.userData![SpriteUserDataKey.stepper] = self

        let offspring = Stepper(core: newCore, metabolism: newMetabolism)
        offspring.gridlet = randomPoint.gridlet

        // This is ugly. The only reason it's here is to hold a ref so the
        // Stepper doesn't go away
        newCore.sprite.stepper = offspring

        if let st = stepper {
            World.shared.incrementCOffspring(for: st.core.selectoid)
            goParent!(st)
        }

        if let goof = goOffspring {
            goof(offspring)
        } else {
            offspring.coordinator.funge()
        }
    }

    private func setOffspringPosition() {
        var randomPoint: Grid.RandomGridPoint?

        Lockable<Grid.RandomGridPoint>().lock({
            randomPoint = self.getGridPointNearParent()

            if randomPoint == nil {
                randomPoint = Grid.getRandomPoint_(background: Arkon.arkonsPortal!)
            }
        }, {
            self.makeStepper_(at: randomPoint!)
        })
    }
}
