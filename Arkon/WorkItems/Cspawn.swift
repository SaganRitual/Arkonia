import SpriteKit

struct CSpawn {
    let allowSpawning = true
    let goOffspring: StepperSimpleCallback?
    let goParent: StepperSimpleCallback?
    weak var parentStepper: Stepper?

    init(
        _ parentStepper: Stepper?,
        goParent: StepperSimpleCallback? = nil,
        goOffspring: StepperSimpleCallback? = nil
    ) {
        self.parentStepper = parentStepper
        self.goOffspring = goOffspring
        self.goParent = goParent
    }

    func spawnProgenitor() {
        Grid.getRandomPoint { randomPoints in
            guard let randomPoint = randomPoints?[0] else { fatalError() }
            self.makeStepper_(at: randomPoint)
        }
    }

    func spawnIf() {
        guard let st = parentStepper else { fatalError() }

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

        asyncQueue.async { self.startOffspringConstruction() }
    }

    private func getGridPointNearParent() -> [Grid.RandomGridPoint]? {

        guard let st = parentStepper else { return nil }

        for offset in Stepper.gridInputs {
            let offspringPosition = st.gridlet.gridPosition + offset

            if Gridlet.isOnGrid(offspringPosition.x, offspringPosition.y) {
                let gridlet = Gridlet.at(offspringPosition)
                if gridlet.contents == .nothing {
                    let r = Grid.RandomGridPoint(
                        gridlet: gridlet, cgPoint: gridlet.scenePosition
                    )

                    return [r]
                }
            }
        }

        return nil
    }

    private func makeStepper_(at randomPoint: Grid.RandomGridPoint) {
        var newCore: Arkon!

        func partB(_ components: [Any]?) {
            let net = components![0] as! Net
            let netDisplay = components![1] as NetDisplay
            let selectoid = components![2] as! Selectoid
            let sprite = components![3] as! SKSpriteNode
        }

        Arkon.startConstruction(
            onComplete: partB,
            parentBiases: parentStepper?.core.net.biases,
            parentWeights: parentStepper?.core.net.weights,
            layers: parentStepper?.core.net.layers,
            parentActivator: parentStepper?.core.net.activatorFunction
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

        if let st = parentStepper {
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
        Grid.lock({ () -> [Grid.RandomGridPoint]? in
            var randomPoint = self.getGridPointNearParent()

            if randomPoint == nil {
                randomPoint = Grid.getRandomPoint_()
            }

            return randomPoint
        }, {
            guard let randomPoint = $0?[0] else { fatalError() }
            self.makeStepper_(at: randomPoint)
        })
    }

    private func startOffspringConstruction() {
        setOffspringPosition()
    }
}

typealias LockRandomPoint = Dispatch.Lockable<Grid.RandomGridPoint>
