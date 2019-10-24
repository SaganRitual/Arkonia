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

    func spawnProgenitor() {
        buildNewArkon()
    }
}

extension ArkonFactory {
    func buildNewArkon() {
        func workItem() -> [Gridlet]? { getStartingGridPosition_(); return nil }
        Grid.lock(workItem, buildWorldStats, .concurrent)
    }

    private func getStartingGridPosition_() {

        if newStepper.parentStepper != nil {
            if let rp = getGridPointNearParent_() {
                newStepper.gridlet = rp
                return
            }
        }

        let gr = Gridlet.getRandomGridlet_()
        newStepper.gridlet = gr![0]
    }

    private func getGridPointNearParent_() -> Gridlet? {
        guard let st = newStepper.parentStepper else { fatalError() }

        for offset in Grid.gridInputs {
            let offspringPosition = st.gridlet.gridPosition + offset

            if Gridlet.isOnGrid(offspringPosition.x, offspringPosition.y) {

                let gridlet = Gridlet.at(offspringPosition)
                if gridlet.contents == .nothing { return gridlet }
            }
        }

        return nil
    }
}

extension ArkonFactory {

    private func buildSprites(_ gridlet: [Gridlet]?) {
        let action = SKAction.run {
            self.configureSprites_()
        }

        GriddleScene.arkonsPortal.run(action) {
            self.finalize_()
        }
    }

    private func configureSprites_() {
        newStepper.nose = ArkonFactory.spriteFactory!.noseHangar.makeSprite()
        newStepper.sprite = ArkonFactory.spriteFactory!.arkonsHangar.makeSprite()

        guard let sprite = newStepper.sprite else { fatalError() }
        guard let nose = newStepper.nose else { fatalError() }
        guard let gridlet = newStepper.gridlet else { fatalError() }

        nose.alpha = 1
        nose.colorBlendFactor = 1

        sprite.setScale(ArkonFactory.scaleFactor)
        sprite.color = ColorGradient.makeColor(hexRGB: 0xFF0000)
        sprite.colorBlendFactor = 1
        sprite.color = .cyan
        sprite.setScale(0.5)
        sprite.position = gridlet.scenePosition

        Stepper.attachStepper(newStepper, to: sprite)

        sprite.addChild(nose)
        GriddleScene.arkonsPortal!.addChild(sprite)
    }

    private func finalize_() {
        guard let gr = newStepper.gridlet else { fatalError() }
        guard let sp = newStepper.sprite else { fatalError() }

        sp.color = .cyan
        sp.setScale(0.5)
        sp.position = gr.scenePosition

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

        if let p = self.goParent {
            print("p goParent")
            World.run { p(self.newStepper.parentStepper!) }
        } else {
            newStepper.shiftStart()
        }

        if let g = self.goOffspring {
            print("g goOffspring")
            World.run { g(self.newStepper) }
        }
    }
}

extension ArkonFactory {
    private func buildWorldStats(_: [Gridlet]?) {
        World.lock(updateWorldStats_, buildSprites, .concurrent)
    }

    private func updateWorldStats_() -> [Gridlet]? {
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

typealias LockRandomPoint = Dispatch.Lockable<Gridlet>
