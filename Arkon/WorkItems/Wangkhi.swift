import SpriteKit

enum Wangkhi {
    static let brightColor = 0x00_FF_00    // Full green
    static let scaleFactor: CGFloat = 0.5
    static var spriteFactory: SpriteFactory!
    static let standardColor = 0x00_FF_00  // Slightly dim green
}

protocol WangkhiProtocol: class {
    var birthday: Int { get set }
    var callAgain: Bool { get }
    var dispatch: Dispatch? { get set }
    var fishNumber: Int { get set }
    var gridlet: Gridlet? { get set }
    var metabolism: Metabolism? { get set }
    var net: Net? { get }
    var netDisplay: NetDisplay? { get }
    var nose: SKSpriteNode? { get set }
    var parent: Stepper? { get set }
    var sprite: SKSpriteNode? { get set }
    var stepper: Stepper? { get set }
}

final class WangkhiEmbryo: Dispatchable, WangkhiProtocol {
    enum Phase {
        case getUnsafeStats, buildGuts, buildSprites
    }

    var birthday = 0
    var callAgain = false
    var dispatch: Dispatch?
    var fishNumber = 0
    var gridlet: Gridlet?
    var metabolism: Metabolism?
    var net: Net?
    var netDisplay: NetDisplay?
    var nose: SKSpriteNode?
    var parent: Stepper?
    var phase = Phase.getUnsafeStats
    var sprite: SKSpriteNode?
    var stepper: Stepper?

    init(_ dispatch: Dispatch) { self.dispatch = dispatch }

    func go() { getUnsafeStats() }
}

extension WangkhiEmbryo {
    func getUnsafeStats() {
        let gr = Gridlet.getRandomGridlet_()
        gridlet = gr![0]

        World.stats.registerBirth_(myParent: nil, meOffspring: self)

        phase = .buildGuts
        dispatch!.callAgain()
    }
}

extension WangkhiEmbryo {
    func buildGuts() {

        metabolism = Metabolism()

        guard let p = self.parent else { fatalError() }
        net = Net(
            parentBiases: p.parentBiases, parentWeights: p.parentWeights,
            layers: p.parentLayers, parentActivator: p.parentActivator
        )

        if let np = (sprite?.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode),
            let scene = np.parent as? SKScene {

            netDisplay = NetDisplay(
                scene: scene, background: np, layers: net!.layers
            )

            netDisplay!.display()
        }

        phase = .buildSprites
        dispatch!.callAgain()
    }

}

extension WangkhiEmbryo {

    func buildSprites() {
        assert((dispatch?.runningAsBarrier ?? false) == true)

        let action = SKAction.run { [unowned self] in self.buildSprites_() }
        GriddleScene.arkonsPortal.run(action)
    }

    private func buildSprites_() {
        assert(Display.displayCycle == .actions)

        self.nose = Wangkhi.spriteFactory!.noseHangar.makeSprite()
        self.sprite = Wangkhi.spriteFactory!.arkonsHangar.makeSprite()

        guard let sprite = self.sprite else { fatalError() }
        guard let nose = self.nose else { fatalError() }
        guard let gridlet = self.gridlet else { fatalError() }

        nose.alpha = 1
        nose.colorBlendFactor = 1

        sprite.setScale(Wangkhi.scaleFactor)
        sprite.color = ColorGradient.makeColor(hexRGB: 0xFF0000)
        sprite.colorBlendFactor = 1
        sprite.setScale(0.5)
        sprite.position = gridlet.scenePosition
        sprite.alpha = 1

        sprite.addChild(nose)

        let newborn: Stepper = Stepper(self)
        Stepper.attachStepper(newborn, to: sprite)
        GriddleScene.arkonsPortal!.addChild(sprite)

        dispatch!.funge()
    }
}
