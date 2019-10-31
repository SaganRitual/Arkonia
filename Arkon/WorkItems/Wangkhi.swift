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

    init(_ dispatch: Dispatch) {
//        print("before",
//              dispatch.name.prefix(8),
//              dispatch.stepper?.name.prefix(8) ?? "wtf1å",
//              self.dispatch?.name.prefix(8) ?? "wtf1a",
//              self.dispatch?.stepper?.name.prefix(8) ?? "wtf1b; ",
//              terminator: "")

        self.dispatch = dispatch

//        print("after",
//              dispatch.name.prefix(8),
//              dispatch.stepper?.name.prefix(8) ?? "wtf2å",
//              self.dispatch?.name.prefix(8) ?? "wtf2a",
//              self.dispatch?.stepper?.name.prefix(8) ?? "wtf2b",
//              terminator: "")

        self.parent = dispatch.stepper

//        print("rafter",
//              dispatch.name.prefix(8),
//              dispatch.stepper?.name.prefix(8) ?? "wtf3å",
//              self.dispatch?.name.prefix(8) ?? "wtf3a",
//              self.dispatch?.stepper?.name.prefix(8) ?? "wtf1b; ")
    }

    func go() { aWangkhiEmbryo() }
}

extension WangkhiEmbryo {
    func aWangkhiEmbryo() {
        switch phase {
        case .getUnsafeStats:
            getUnsafeStats()
            phase = .buildGuts
            dispatch!.callAgain()

        case .buildGuts:
            buildGuts()
            phase = .buildSprites
            dispatch!.callAgain()

        case .buildSprites:
            buildSprites()
        }
    }
}

extension WangkhiEmbryo {
    func getUnsafeStats() {
        assert((dispatch?.runningAsBarrier ?? false) == true)
        let gr = Gridlet.getRandomGridlet_()
        gridlet = gr![0]

        World.stats.registerBirth_(myParent: nil, meOffspring: self)
    }
}

extension WangkhiEmbryo {
    func buildGuts() {
        assert((dispatch?.runningAsBarrier ?? false) == true)

        metabolism = Metabolism()

        net = Net(
            parentBiases: parent?.parentBiases, parentWeights: parent?.parentWeights,
            layers: parent?.parentLayers, parentActivator: parent?.parentActivator
        )

        if let np = (sprite?.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode),
            let scene = np.parent as? SKScene {

            netDisplay = NetDisplay(
                scene: scene, background: np, layers: net!.layers
            )

            netDisplay!.display()
        }
    }

}

extension WangkhiEmbryo {

    func buildSprites() {
        assert((dispatch?.runningAsBarrier ?? false) == true)

        let action = SKAction.run { [unowned self] in self.buildSprites_() }
        GriddleScene.arkonsPortal.run(action)
    }

    //swiftmint:disable function_body_length
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

//        print("bbefore",
//              dispatch?.name.prefix(8) ?? "wtf4∫",
//              dispatch?.stepper?.name.prefix(8) ?? "wtf14å",
//              dispatch?.stepper?.parentStepper?.name ?? "no parent4 ",
//              dispatch?.stepper?.parentStepper?.dispatch?.name ?? "no parent4a ",
//              self.dispatch?.name.prefix(8) ?? "wtf4a",
//              self.dispatch?.stepper?.name.prefix(8) ?? "wtf4b; ")

        let newborn: Stepper = Stepper(self, needsNewDispatch: true)
        newborn.parentStepper = self.dispatch?.stepper
        newborn.dispatch.stepper = newborn

//        print("bbefore2",
//              dispatch?.name.prefix(8) ?? "wtf5∫",
//              dispatch?.stepper?.name.prefix(8) ?? "wtf15å",
//              dispatch?.stepper?.parentStepper?.name ?? "no parent5 ",
//              dispatch?.stepper?.parentStepper?.dispatch?.name ?? "no parent5a ",
//              self.dispatch?.name.prefix(8) ?? "wtf4a",
//              self.dispatch?.stepper?.name.prefix(8) ?? "wtf5b; ",

//              newborn.name.prefix(8),
//              newborn.parentStepper?.name ?? "no parent7 ",
//              newborn.parentStepper?.dispatch?.name ?? "no parent7a ")

        Stepper.attachStepper(newborn, to: sprite)
        newborn.dispatch!.tempStrongReference = nil

//        print("bbefore3",
//              dispatch?.name.prefix(8) ?? "wtf6∫",
//              dispatch?.stepper?.name.prefix(8) ?? "wtf146",
//              dispatch?.stepper?.parentStepper?.name ?? "no parent6 ",
//              dispatch?.stepper?.parentStepper?.dispatch?.name ?? "no parent6a ",
//              self.dispatch?.name.prefix(8) ?? "wtf6a",
//              self.dispatch?.stepper?.name.prefix(8) ?? "wtf6b; ",
//
//              newborn.name.prefix(8),
//              newborn.parentStepper?.name ?? "no parent8 ",
//              newborn.parentStepper?.dispatch?.name ?? "no parent8a ")

        GriddleScene.arkonsPortal!.addChild(sprite)

//        print("birth0")
        if let dp = self.dispatch, let st = dp.stepper {
//            print("parent0")

            let spawnCost = st.getSpawnCost()
            st.metabolism.withdrawFromSpawn(spawnCost)

            dp.funge()
//            print("parent1")
        }

//        print("birth1")

        newborn.dispatch!.funge()

//        print("child")
    }
    //swiftmint:enable function_body_length
}
