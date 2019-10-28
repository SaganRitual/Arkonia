import SpriteKit

final class Spawn: Dispatchable {
    static let brightColor = 0x00_FF_00    // Full green
    static let scaleFactor: CGFloat = 0.5
    static var shared: ArkonFactory!
    static var spriteFactory: SpriteFactory!
    static let standardColor = 0x00_FF_00  // Slightly dim green

    enum Phase {
        case getLanding, buildWorldStats, buildSprites
        case launch
    }

    var isMakingCommoner = true
    weak var dispatch: Dispatch!
    var phase = Phase.getLanding
    var newStepper: Stepper { return dispatch.stepper }
    weak var parentStepper: Stepper?

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
    }

    func go() { aSpawn() }

    func inject(_ parentStepper: Stepper?) { self.parentStepper = parentStepper }
}

extension Spawn {

    func aSpawn() {
        assert(dispatch.runningAsBarrier == true)

        switch phase {
        case .getLanding:
            getLanding()
            phase = .buildWorldStats

        case .buildWorldStats:
            buildWorldStats()
            phase = .buildSprites

        case .buildSprites:
            buildSprites()
            phase = .launch

        case .launch:
            launch()
            return
        }

        dispatch.spawnCommoner()
    }

}

extension Spawn {

    func buildSprites() {
        let action = SKAction.run { self.buildSprites_() }
        GriddleScene.arkonsPortal.run(action)
    }

    private func buildSprites_() {
        assert(Display.displayCycle == .actions)

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
    //        sprite.color = .cyan
        sprite.setScale(0.5)
        sprite.position = gridlet.scenePosition
        sprite.alpha = 1

        Stepper.attachStepper(newStepper, to: sprite)

        sprite.addChild(nose)
        GriddleScene.arkonsPortal!.addChild(sprite)
    }

    private func launch() {
        assert(dispatch.runningAsBarrier == true)

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

        if isMakingCommoner {
            self.dispatch.metabolize()
        }

        newStepper.dispatch.funge()
    }
}

extension Spawn {
    private func buildWorldStats() {
        World.stats.registerBirth_(self.parentStepper, self.newStepper)
    }
}
