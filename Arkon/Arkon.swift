import Foundation
import SpriteKit

struct Selectoid {
    static var TheFishNumber = 0

    let birthday: TimeInterval
    var cOffspring = 0
    let fishNumber: Int

    init(birthday: TimeInterval) {
        defer { Selectoid.TheFishNumber += 1 }
        fishNumber = Selectoid.TheFishNumber

        self.birthday = birthday
    }
}

extension SpriteFactory {
    static func makeSprite(texture: SKTexture) -> SKSpriteNode {
        return SKSpriteNode(texture: texture)
    }
}

protocol MetabolismProtocol: class {
    var fungibleEnergyFullness: CGFloat { get }
    var oxygenLevel: CGFloat { get set }
    var spawnEnergyFullness: CGFloat { get }
    var spawnReserves: EnergyReserve { get }

    func absorbEnergy(_ cJoules: CGFloat)
    func tick()
    @discardableResult func withdrawFromSpawn(_ cJoules: CGFloat) -> CGFloat
}

protocol HasMetabolism {
    var metabolism: MetabolismProtocol { get }
}

class Arkon {
    static let brightColor = 0x00_FF_00    // Full green
    static var clock: TimeInterval?
    static var layers: [Int]?
    static var arkonsPortal: SKSpriteNode?
    static let scaleFactor: CGFloat = 0.5
    static var spriteFactory: SpriteFactory?
    static let standardColor = 0x00_FF_00  // Slightly dim green

    var isCaptured = false
    let net: Net
    var netDisplay: NetDisplay!

    let nose: SKSpriteNode
    var previousPosition = CGPoint.zero
    var arkonsPortal: SKSpriteNode { return Arkon.arkonsPortal! }
    var selectoid: Selectoid
    var sensoryInputs = [Double]()
    let sprite: SKSpriteNode
    var spriteFactory: SpriteFactory { return Arkon.spriteFactory! }

    var age: TimeInterval { World.shared.currentTime - selectoid.birthday }

    init(
        parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?,
        parentActivator: ((_: Double) -> Double)?
    ) {

        selectoid = Selectoid(birthday: World.shared.currentTime)
        net = Net(
            parentBiases: parentBiases, parentWeights: parentWeights,
            layers: layers, parentActivator: parentActivator
        )

        sprite = Arkon.spriteFactory!.arkonsHangar.makeSprite()
        sprite.setScale(Arkon.scaleFactor)
        sprite.color = ColorGradient.makeColor(hexRGB: Arkon.standardColor)
        if selectoid.fishNumber < 10 {
            sprite.color = ColorGradient.makeColor(hexRGB: 0xFF0000)
        }
        sprite.colorBlendFactor = 1

        if let np = (sprite.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode),
            let scene = np.parent as? SKScene {

            netDisplay = NetDisplay(scene: scene, background: np, layers: net.layers)
            netDisplay!.display()
        }

        nose = Arkon.spriteFactory!.noseHangar.makeSprite()
        nose.alpha = 1
        nose.colorBlendFactor = 1

        sprite.addChild(nose)
        Arkon.arkonsPortal!.addChild(sprite)

        World.shared.population += 1
    }

    deinit {
        World.shared.population -= 1

        netDisplay = nil
    }

    func tick() {
        World.shared.registerAge(age)
    }
}

extension Arkon {
//    static var arkonHangar = [Int: Arkon]()

    static func inject(
        _ layers: [Int],  _ portal: SKSpriteNode,
        _ spriteFactory: SpriteFactory
    ) {
        Arkon.layers = layers
        Arkon.arkonsPortal = portal
        Arkon.spriteFactory = spriteFactory
    }
}
