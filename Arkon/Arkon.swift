import Foundation
import SpriteKit

class Selectoid {
    static var TheFishNumber = 0

    let birthday: TimeInterval
    var cOffspring = 0
    let fishNumber: Int

    init(birthday: TimeInterval) {
        print("2")
        defer {
            print("3", fishNumber)
            Selectoid.TheFishNumber += 1
            print("4", fishNumber)
        }
        fishNumber = Selectoid.TheFishNumber

        self.birthday = birthday
        print("5", fishNumber)
    }

    deinit {
        print("~Selectoid")
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

    weak var nose: SKSpriteNode!
    var previousPosition = CGPoint.zero
    var arkonsPortal: SKSpriteNode { return Arkon.arkonsPortal! }
    var selectoid: Selectoid!
    var sensoryInputs = [Double]()
    var sprite: SKSpriteNode!
    var spriteFactory: SpriteFactory { return Arkon.spriteFactory! }

    static func startConstruction(
        onComplete: Dispatch.Lockable<Any>.LockOnComplete,
        parentBiases: [Double]?,
        parentWeights: [Double]?,
        layers: [Int]?,
        parentActivator: ((_: Double) -> Double)?
    ) {
        let net = Net(
            parentBiases: parentBiases, parentWeights: parentWeights,
            layers: layers, parentActivator: parentActivator
        )

        partB(net, onComplete)
    }

    static func partB(
         _ net: Net, _ onComplete: Dispatch.Lockable<Any>.LockOnComplete
    ) {
        Grid.lock({ () -> [SKSpriteNode]? in
            let nose = Arkon.spriteFactory!.noseHangar.makeSprite()
            let sprite = Arkon.spriteFactory!.arkonsHangar.makeSprite()

            return [sprite, nose]
        }, {
            guard let sprite = $0?[0] else { fatalError() }
            guard let nose = $0?[1] else { fatalError() }

            nose.alpha = 1
            nose.colorBlendFactor = 1

            sprite.setScale(Arkon.scaleFactor)
//                sprite.color = ColorGradient.makeColor(hexRGB: Arkon.standardColor)
            sprite.color = ColorGradient.makeColor(hexRGB: 0xFF0000)
            sprite.colorBlendFactor = 1

            print("A", nose.name!)
            sprite.addChild(nose)
            print("B", sprite.name!)
            Arkon.arkonsPortal!.addChild(sprite)
            print("C")

            partC(net, sprite, onComplete)
        })
    }

    static func partC(
        _ net: Net, _ sprite: SKSpriteNode,
        _ onComplete: Dispatch.Lockable<Any>.LockOnComplete
    ) {
        World.shared.getCurrentTime { t in
            print("0")
            let selectoid = Selectoid(birthday: t![0])
            print("1", selectoid.fishNumber)
            World.shared.incrementPopulation()

            asyncQueue.async(execute: { partD(net, sprite, selectoid, onComplete) })
        }
    }

    static func partD(
        _ net: Net,
        _ sprite: SKSpriteNode,
        _ selectoid: Selectoid,
        _ onComplete: Dispatch.Lockable<Any>.LockOnComplete
    ) {
        var netDisplay: NetDisplay?
        if let np = (sprite.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode),
            let scene = np.parent as? SKScene {

            netDisplay = NetDisplay(scene: scene, background: np, layers: net.layers)
            netDisplay!.display()
        }

        onComplete([net, netDisplay as Any, selectoid, sprite])
    }

    deinit {
        print("~Arkon")
        World.shared.decrementPopulation()

        netDisplay = nil
        print("/~Arkon")
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
