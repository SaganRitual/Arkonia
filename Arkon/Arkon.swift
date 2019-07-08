import Foundation
import SpriteKit

struct Selectoid {
    static var TheFishNumber = 0

    let birthday: TimeInterval
//    var cOffspring: Int
    let fishNumber: Int
//    let fishNumberOfParent: Int?
//    let genome: [GeneProtocol]
//    let genomeOfParent: [GeneProtocol]?

    init(birthday: TimeInterval) {
        defer { Selectoid.TheFishNumber += 1 }
        fishNumber = Selectoid.TheFishNumber

        self.birthday = birthday
    }
}

extension SKPhysicsBody: Massive {}

extension SKSpriteNode {
    var arkon: Arkon {
        get { return (userData![SpriteUserDataKey.arkon] as? Arkon)! }
        set { userData![SpriteUserDataKey.arkon] = newValue }
    }
}

extension SpriteFactory {
    static func makeNose(texture: SKTexture) -> SKSpriteNode {
        return Nose(texture: texture)
    }

    static func makeSprite(texture: SKTexture) -> SKSpriteNode {
        return SKSpriteNode(texture: texture)
    }

    static func makeThorax(texture: SKTexture) -> SKSpriteNode {
        return Thorax(texture: texture)
    }
}

class Arkon: HasContactDetector {
    static let brightColor = 0x00_FF_00    // Full green
    static var clock: ClockProtocol?
    static var layers: [Int]?
    static var arkonsPortal: SKSpriteNode?
    static let scaleFactor: CGFloat = 0.5
    static var spriteFactory: SpriteFactory?
    static let standardColor = 0x00_D0_00  // Slightly dim green

    var contactDetector: ContactDetectorProtocol?
    var isAlive = false
    var isCaptured = false
    let metabolism: Metabolism
    let net: Net

    var netQueue = DispatchQueue(
        label: "arkonia.net.queue", qos: .background, attributes: .concurrent
    )

    let nose: SKSpriteNode
    var arkonsPortal: SKSpriteNode { return Arkon.arkonsPortal! }
    var selectoid: Selectoid
    var senseLoader: SenseLoader!
    var sensoryInputs = [Double]()
    let sprite: SKSpriteNode
    var spriteFactory: SpriteFactory { return Arkon.spriteFactory! }

    var age: TimeInterval { Arkon.clock!.getCurrentTime() - selectoid.birthday }

    var pBody: SKPhysicsBody { return sprite.physicsBody! }

    //swiftmint:disable function_body_length
    init(parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?) {
        selectoid = Selectoid(birthday: Arkon.clock!.getCurrentTime())
        net = Net(parentBiases: parentBiases, parentWeights: parentWeights, layers: layers)

        sprite = Arkon.spriteFactory!.arkonsHangar.makeSprite()
        sprite.setScale(Arkon.scaleFactor)
        sprite.color = ColorGradient.makeColor(hexRGB: Arkon.standardColor)
        sprite.colorBlendFactor = 1

        if let np = (sprite.userData?[SpriteUserDataKey.net9Portal] as? SKSpriteNode),
            let scene = np.parent as? SKScene {

            NetDisplay(scene: scene, background: np, layers: net.layers).display()
        }

        let spritePhysicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)

        spritePhysicsBody.categoryBitMask = PhysicsBitmask.arkonBody.rawValue
        spritePhysicsBody.collisionBitMask = PhysicsBitmask.arkonBody.rawValue

        spritePhysicsBody.contactTestBitMask =
            PhysicsBitmask.arkonBody.rawValue |
            PhysicsBitmask.mannaBody.rawValue

        spritePhysicsBody.mass = 1
        contactDetector = ContactDetector()

        nose = Arkon.spriteFactory!.noseHangar.makeSprite()
        nose.alpha = 1
        nose.colorBlendFactor = 1

//        let topReserveIndicator = SKLabelNode(text: "here")
//        topReserveIndicator.fontName = "Courier New"
//        topReserveIndicator.fontColor = .white
//        topReserveIndicator.text = "hello!"
//        topReserveIndicator.position = CGPoint(x: 50, y: 75)
//        topReserveIndicator.fontSize = 64
//        topReserveIndicator.zRotation = 0
//        nose.addChild(topReserveIndicator)
//
//        let bottomReserveIndicator = SKLabelNode(text: "here")
//        bottomReserveIndicator.fontName = "Courier New"
//        bottomReserveIndicator.fontColor = .white
//        bottomReserveIndicator.text = "hello!"
//        bottomReserveIndicator.position = CGPoint(x: 50, y: -75)
//        bottomReserveIndicator.fontSize = 64
//        bottomReserveIndicator.zRotation = 0
//        nose.addChild(bottomReserveIndicator)

        let nosePhysicsBody = SKPhysicsBody(circleOfRadius: nose.size.width * 2)

        nosePhysicsBody.categoryBitMask = PhysicsBitmask.arkonSenses.rawValue
        nosePhysicsBody.collisionBitMask = 0

        nosePhysicsBody.contactTestBitMask =
            PhysicsBitmask.arkonBody.rawValue |
            PhysicsBitmask.mannaBody.rawValue

        nosePhysicsBody.mass = 0.1
        nosePhysicsBody.pinned = true

        metabolism = Metabolism(spritePhysicsBody)

        sprite.position = arkonsPortal.getRandomPoint()
        sprite.addChild(nose)
        arkonsPortal.addChild(sprite)

        sprite.userData![SpriteUserDataKey.arkon] = self

        sprite.physicsBody = spritePhysicsBody
        nose.physicsBody = nosePhysicsBody

        contactDetector!.isReadyForPhysics = true
    }
    //swiftmint:enable function_body_length

    deinit {
    }

    func apoptosize() {
        spriteFactory.noseHangar.retireSprite(sprite.arkon.nose)
        spriteFactory.arkonsHangar.retireSprite(sprite)
    }

    func tick() {
        let realScene = (arkonsPortal.parent as? SKScene)!
        let converted = arkonsPortal.convert(sprite.position, to: realScene)

        guard arkonsPortal.frame.contains(converted) else {
            apoptosize()
            return
        }

        metabolism.tick()
    }
}

extension Arkon {
    static var arkonHangar = [Int: Arkon]()

    static func inject(
        _ clock: ClockProtocol, _ layers: [Int],  _ portal: SKSpriteNode,
        _ spriteFactory: SpriteFactory
    ) {
        Arkon.clock = clock
        Arkon.layers = layers
        Arkon.arkonsPortal = portal
        Arkon.spriteFactory = spriteFactory

        SenseLoader.inject(portal)
    }

    @discardableResult
    static func spawn(parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?) -> Arkon {

        let newArkon = Arkon(
            parentBiases: parentBiases, parentWeights: parentWeights, layers: layers
        )

        arkonHangar[newArkon.selectoid.fishNumber] = newArkon
        newArkon.sprite.position = Arkon.arkonsPortal!.getRandomPoint()
        newArkon.sprite.zRotation = CGFloat.random(in: -CGFloat.pi..<CGFloat.pi)

        newArkon.contactDetector!.contactResponder =
            ContactResponder(ownerArkon: newArkon)

        newArkon.contactDetector!.senseResponder = SenseResponder()

        onePass(sprite: newArkon.sprite, metabolism: newArkon.metabolism)

        return newArkon
    }
}

extension Arkon {

    static func onePass(sprite thorax: SKSpriteNode, metabolism: Metabolism) {
        let nose = (thorax.children[0] as? Nose)!

//        print("o2a", thorax.arkon.selectoid.fishNumber, metabolism.oxygenLevel, terminator: "")
        metabolism.oxygenLevel -= (1.0 / 60.0)
//        print("o2b", metabolism.oxygenLevel)

        guard metabolism.fungibleEnergyFullness > 0 && metabolism.oxygenLevel > 0 else {
            thorax.arkon.apoptosize()
            return
        }

        // 10% entropy
        let spawnCost = EnergyReserve.startingEnergyLevel * 1.10

        if metabolism.spawnReserves.level >= spawnCost {
            metabolism.withdrawFromSpawn(spawnCost)

            Arkon.spawn(
                parentBiases: thorax.arkon.net.biases,
                parentWeights: thorax.arkon.net.weights,
                layers: thorax.arkon.net.layers
            )
        }

        let ef = metabolism.fungibleEnergyFullness
        nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

        let baseColor = (metabolism.spawnEnergyFullness > 0) ?
            Arkon.brightColor : Arkon.standardColor

        thorax.color = ColorGradient.makeColorMixRedBlue(
            baseColor: baseColor,
            redPercentage: metabolism.spawnEnergyFullness,
            bluePercentage: max((4 - CGFloat(thorax.arkon.age)) / 4, 0)
        )

        //        print("color", metabolism.spawnEnergyFullness, max((4 - CGFloat(thorax.arkon.age)) / 4, 0))

        //        let topLabel = (nose.children[0] as? SKLabelNode)!
        //        topLabel.text = String(format: "%0.0f", metabolism.readyEnergyReserves.level)
        //
        //        let bottomLabel = (nose.children[1] as? SKLabelNode)!
        //        bottomLabel.text = String(format: "%0.0f", metabolism.fatReserves.level)

        //        let maneuvers = Maneuvers(energySource: metabolism)
        //        let actions = getActions(sprite: thorax, maneuvers: maneuvers)
        //
        ////        print("nass", sprite.physicsBody!.mass, metabolism.energyFullness)//, nosePhysicsBody.mass)
        //        let spreadem = CGFloat(thorax.arkon.selectoid.fishNumber % 5) * CGFloat.random(in: 0..<5)
        //        let wait = SKAction.wait(forDuration: TimeInterval(spreadem * 0.016))
        //        let randomness = SKAction.sequence([wait, actions])
        //
        //        thorax.run(randomness) { onePass(sprite: thorax, metabolism: metabolism) }

        brainlyManeuverStart(sprite: thorax, metabolism: metabolism)
    }

    static func brainlyManeuverStart(sprite thorax: SKSpriteNode, metabolism: Metabolism) {

        let sensoryInputs = thorax.arkon.stimulus()

        var motorOutputs = [Double]()
        let workItem = DispatchWorkItem {
            motorOutputs = thorax.arkon.net.getMotorOutputs(sensoryInputs)
            brainlyManeuverEnd(sprite: thorax, metabolism: metabolism, motorOutputs: motorOutputs)
        }

        thorax.arkon.netQueue.async(execute: workItem)
    }

    static func brainlyManeuverEnd(sprite thorax: SKSpriteNode, metabolism: Metabolism, motorOutputs: [Double]) {
        let maneuvers = Maneuvers(energySource: metabolism)
        let action = maneuvers.selectActionPrimitive(arkon: thorax, motorOutputs: motorOutputs)
        let wait = SKAction.wait(forDuration: 0.01)
        let sequence = SKAction.sequence([wait, action])
        thorax.run(sequence) { onePass(sprite: thorax, metabolism: metabolism) }
    }
}

extension Arkon {

    class ContactResponder: ContactResponseProtocol {
        let ownerArkon: Arkon
        var processingTouch = false

        init(ownerArkon: Arkon) { self.ownerArkon = ownerArkon }

        func respond(_ contactedBodies: [SKPhysicsBody]) {
            for body in contactedBodies {
                switch body.node {
                case let t as Thorax:
                    if touchArkon(t) {
                        return
                    }

                case let m as SKSpriteNode:
                    touchManna(m.manna)
                    return

                default: assert(false)
                }
            }
        }

        func touchArkon(_ thorax: Thorax) -> Bool {
            if processingTouch { return false }
            processingTouch = true
            defer { processingTouch = false }

//            if thorax.arkon.selectoid.fishNumber < ownerArkon.selectoid.fishNumber {
//                ownerArkon.metabolism.parasitize(thorax.arkon.metabolism)
//                return true
//            }

            return false
        }

        func touchManna(_ manna: Manna) {
            if processingTouch { return }
            processingTouch = true
            defer { processingTouch = false }

            let sprite = manna.sprite
            let background = (sprite.parent as? SKSpriteNode)!

            let harvested = sprite.manna.harvest()
            ownerArkon.metabolism.absorbEnergy(harvested)

            let actions = Manna.triggerDeathCycle(sprite: sprite, background: background)
            sprite.run(actions)
        }
    }

    struct SenseResponder: SenseResponseProtocol {
        func respond(_ sensedBodies: [SKPhysicsBody]) {
            //            sensedBodies.forEach { ($0.node as? SKSpriteNode)?.color = .yellow }
        }
    }
}
