import SpriteKit

class NewStepper {
    weak var parentStepper: NewStepper?
    var cOffspring = 0
}

struct ArkonFactory {
    static let brightColor = 0x00_FF_00    // Full green
    static let scaleFactor: CGFloat = 0.5
    static var shared: ArkonFactory!
    static var spriteFactory: SpriteFactory!
    static let standardColor = 0x00_FF_00  // Slightly dim green

    let allowSpawning = true
    let goOffspring: Stepper.OnComplete1?
    let goParent: Stepper.OnComplete1?

    var newStepper: Stepper

    init(
        _ parentStepper: Stepper? = nil,
        goParent: Stepper.OnComplete1? = nil,
        goOffspring: Stepper.OnComplete1? = nil
    ) {
        self.goOffspring = goOffspring
        self.goParent = goParent

        self.newStepper = Stepper(parentStepper)
    }

    func spawnCommoner() {
        guard let st = newStepper.parentStepper else { fatalError() }

        let entropy: CGFloat = 0.1

        let spawnCost = allowSpawning ?
            EnergyReserve.startingEnergyLevel * CGFloat(1.0 + entropy) :
            CGFloat.infinity

        if st.metabolism.spawnReserves.level < spawnCost {
            goParent!(st)
            return
        }

        st.metabolism.withdrawFromSpawn(spawnCost)
        buildNewArkon()
    }

    func spawnProgenitor() { buildNewArkon() }
}

extension ArkonFactory {
    private func buildNewArkon() {
        Grid.lock(getStartingGridPosition_, buildWorldStats, .concurrent)
    }

    private func getStartingGridPosition_() -> [Grid.RandomGridPoint]? {

        if newStepper.parentStepper != nil {
            if let rp = getGridPointNearParent_() { return [rp] }
        }

        guard let rp = Grid.getRandomPoint_() else { fatalError() }

        newStepper.gridletWithRandom = rp[0]
        return rp
    }

    private func getGridPointNearParent_() -> Grid.RandomGridPoint? {
        guard let st = newStepper.parentStepper else { fatalError() }

        for offset in Grid.gridInputs {
            let offspringPosition = st.gridlet.gridPosition + offset

            if Gridlet.isOnGrid(offspringPosition.x, offspringPosition.y) {

                let gridlet = Gridlet.at(offspringPosition)
                if gridlet.contents == .nothing {

                    let rp = Grid.RandomGridPoint(
                        gridlet: gridlet, cgPoint: gridlet.scenePosition
                    )

                    return rp
                }
            }
        }

        return nil
    }
}

extension ArkonFactory {

    private func buildSprites(_ gridPosition: [Grid.RandomGridPoint]?) {
        Grid.lock(getDrones_)
    }

    private func configureSprites_() {
        guard let sprite = newStepper.sprite else { fatalError() }
        guard let nose = newStepper.nose else { fatalError() }
        guard let gridlet = newStepper.gridletWithRandom else { fatalError() }

        nose.alpha = 1
        nose.colorBlendFactor = 1

        sprite.setScale(ArkonFactory.scaleFactor)
        sprite.color = ColorGradient.makeColor(hexRGB: 0xFF0000)
        sprite.colorBlendFactor = 1
        sprite.color = .cyan
        sprite.setScale(0.5)
        sprite.position = gridlet.cgPoint

        print("A", nose.name!)
        sprite.addChild(nose)
        print("B", sprite.name!)
        GriddleScene.arkonsPortal!.addChild(sprite)
        print("C")

        World.run(finalize_)
    }

    private func getDrones_() -> [SKSpriteNode]? {
        newStepper.nose = ArkonFactory.spriteFactory!.noseHangar.makeSprite()
        newStepper.sprite = ArkonFactory.spriteFactory!.arkonsHangar.makeSprite()

        World.run(configureSprites_)
        return nil
    }

    private func finalize_() {
        guard let rp = newStepper.gridletWithRandom else { fatalError() }
        guard let sp = newStepper.sprite else { fatalError() }

        sp.color = .cyan
        sp.setScale(0.5)
        sp.position = rp.cgPoint

        newStepper.metabolism = Metabolism()

        newStepper.net = Net(
            parentBiases: newStepper.parentBiases, parentWeights: newStepper.parentWeights,
            layers: newStepper.parentLayers, parentActivator: newStepper.parentActivator
        )

        if let np = (newStepper.sprite?.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode),
            let scene = np.parent as? SKScene {

            newStepper.netDisplay = NetDisplay(
                scene: scene, background: np, layers: newStepper.net!.layers
            )

            newStepper.netDisplay!.display()
        }
    }
}

extension ArkonFactory {
    private func buildWorldStats(_ notUsed: [Grid.RandomGridPoint]?) {
        World.lock(updateWorldStats_, buildSprites, .concurrent)
    }

    private func updateWorldStats_() -> [Grid.RandomGridPoint]? {
        if let bandaid = newStepper.bandaid {
            bandaid.cOffspring += 1
            World.shared.registerCOffspring_(bandaid.cOffspring)
        }

        newStepper.birthday = World.shared.getCurrentTime_()
        newStepper.fishNumber = World.shared.getFishNumber_()

        World.shared.incrementPopulation_()
        return nil
    }
}

typealias LockRandomPoint = Dispatch.Lockable<Grid.RandomGridPoint>
