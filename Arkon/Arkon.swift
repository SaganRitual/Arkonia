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
        get { return (userData!["arkon"] as? Arkon)! }
        set { userData!["arkon"] = newValue }
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
    static let standardColor = 0x00_D0_00  // Slightly dim green
    static let brightColor = 0x00_FF_00    // Full green
    static let scaleFactor: CGFloat = 0.5
    var contactDetector: ContactDetectorProtocol?
    var isAlive = false
    var isCaptured = false
    let metabolism: Metabolism
    let net: Net
    let nose: SKSpriteNode
    var selectoid: Selectoid
    var scene: SKSpriteNode { return Arkon.portal! }
    var senseLoader: SenseLoader!
    var sensoryInputs = [Double]()
    let sprite: SKSpriteNode
    var spriteFactory: SpriteFactory { return Arkon.spriteFactory! }

    var age: TimeInterval { Arkon.clock!.getCurrentTime() - selectoid.birthday }

    var pBody: SKPhysicsBody { return sprite.physicsBody! }

    //swiftmint:disable function_body_length
    init(parentBiases: [Double]?, parentWeights: [Double]?) {
        selectoid = Selectoid(birthday: Arkon.clock!.getCurrentTime())
        net = Net(parentBiases: parentBiases, parentWeights: parentWeights)

        sprite = Arkon.spriteFactory!.arkonsHangar.makeSprite()
        sprite.setScale(Arkon.scaleFactor)
        sprite.color = ColorGradient.makeColor(hexRGB: Arkon.standardColor)
        sprite.colorBlendFactor = 1

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

        sprite.position = scene.getRandomPoint()
        sprite.addChild(nose)
        scene.addChild(sprite)

        sprite.userData = ["arkon": self]

        sprite.physicsBody = spritePhysicsBody
        nose.physicsBody = nosePhysicsBody

        contactDetector!.isReadyForPhysics = true
    }
    //swiftmint:enable function_body_length

    func apoptosize() {
        spriteFactory.noseHangar.retireSprite(sprite.arkon.nose)
        spriteFactory.arkonsHangar.retireSprite(sprite)
    }

    func tick() {
//        print("time", Arkon.clock!.getCurrentTime(), age)
        let realScene = (scene.parent as? SKScene)!
        let converted = scene.convert(sprite.position, to: realScene)

        guard scene.frame.contains(converted) else {
            apoptosize()
            return
        }

//        sprite.color = .green
        metabolism.tick()
    }
}

extension Arkon {
    static var arkonHangar = [Int: Arkon]()
    static var clock: ClockProtocol?
    static var portal: SKSpriteNode?
    static var spriteFactory: SpriteFactory?

    static func getActions(sprite: SKSpriteNode, maneuvers: Maneuvers) -> SKAction {
        let actions = SKAction.sequence([
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 1, 0, 0]),  // thrust
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [0.5, 0, 0, 0, 1]),  // wait
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 1, 0, 0, 0]),  // stop
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [0.5, 0, 0, 0, 1]),  // wait
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 0, 1, 0]),  // rotate
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [0.5, 0, 0, 0, 1]),  // wait
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 1, 0, 0, 0]),  // stop
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [0.5, 0, 0, 0, 1])  // wait
        ])

        return actions
    }

    struct ContactTestContactResponder: ContactResponseProtocol {
        func respond(_ contactedBodies: [SKPhysicsBody]) {
            contactedBodies.forEach { ($0.node as? SKSpriteNode)?.color = .blue }
        }
    }

    struct ContactTestSenseResponder: SenseResponseProtocol {
        func respond(_ sensedBodies: [SKPhysicsBody]) {
            sensedBodies.forEach { ($0.node as? SKSpriteNode)?.color = .yellow }
        }
    }

    static func contactTest() {
        for a in 0..<1 {
            let newArkon = Arkon(parentBiases: nil, parentWeights: nil)
            arkonHangar[a] = newArkon
            newArkon.sprite.position = CGPoint.zero

            newArkon.contactDetector!.contactResponder = ContactTestContactResponder()
            newArkon.contactDetector!.senseResponder = ContactTestSenseResponder()

            onePass(sprite: newArkon.sprite, metabolism: newArkon.metabolism)
        }
    }

    struct CannibalsTestContactResponder: ContactResponseProtocol {
        let ownerArkon: Arkon

        func respond(_ contactedBodies: [SKPhysicsBody]) {
            for body in contactedBodies where body.node is Thorax {
                let sprite = (body.node as? SKSpriteNode)!
                if sprite.arkon.selectoid.fishNumber < ownerArkon.selectoid.fishNumber {
                    ownerArkon.metabolism.parasitize(sprite.arkon.metabolism)
                    break
                }
            }
        }
    }

    struct CannibalsTestSenseResponder: SenseResponseProtocol {
        func respond(_ sensedBodies: [SKPhysicsBody]) {
            sensedBodies.forEach { ($0.node as? SKSpriteNode)?.color = .yellow }
        }
    }

    static func cannibalsTest(portal: SKSpriteNode) {
        for a in 0..<30 {
            let newArkon = Arkon(parentBiases: nil, parentWeights: nil)
            arkonHangar[a] = newArkon
            newArkon.sprite.position = portal.getRandomPoint()
            newArkon.sprite.zRotation = CGFloat.random(in: -CGFloat.pi..<CGFloat.pi)

            newArkon.contactDetector!.contactResponder =
                PreyTestContactResponder(ownerArkon: newArkon)

            newArkon.contactDetector!.senseResponder = PreyTestSenseResponder()

            onePass(sprite: newArkon.sprite, metabolism: newArkon.metabolism)
        }
    }

    struct GrazeTestContactResponder: ContactResponseProtocol {
        let ownerArkon: Arkon

        func respond(_ contactedBodies: [SKPhysicsBody]) {
            for body in contactedBodies {
                let sprite = (body.node as? SKSpriteNode)!
                let background = (sprite.parent as? SKSpriteNode)!

                let harvested = sprite.manna.harvest()
                ownerArkon.metabolism.absorbEnergy(harvested)

                let actions = Manna.triggerDeathCycle(sprite: sprite, background: background)
                sprite.run(actions)
            }
        }

    }

    static func grazeTest() {
        for a in 0..<1 {
            let newArkon = Arkon(parentBiases: nil, parentWeights: nil)
            arkonHangar[a] = newArkon
            newArkon.sprite.position = CGPoint.zero

            newArkon.contactDetector!.contactResponder =
                GrazeTestContactResponder(ownerArkon: newArkon)

            newArkon.contactDetector!.senseResponder = ContactTestSenseResponder()

            onePass(sprite: newArkon.sprite, metabolism: newArkon.metabolism)
        }
    }

    static func inject(
        _ clock: ClockProtocol,  _ portal: SKSpriteNode, _ spriteFactory: SpriteFactory
    ) {
        Arkon.clock = clock
        Arkon.portal = portal
        Arkon.spriteFactory = spriteFactory

        SenseLoader.inject(portal)
    }

    class OmnivoresTestContactResponder: ContactResponseProtocol {
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

            if thorax.arkon.selectoid.fishNumber < ownerArkon.selectoid.fishNumber {
                ownerArkon.metabolism.parasitize(thorax.arkon.metabolism)
                return true
            }

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

    struct OmnivoresTestSenseResponder: SenseResponseProtocol {
        func respond(_ sensedBodies: [SKPhysicsBody]) {
//            sensedBodies.forEach { ($0.node as? SKSpriteNode)?.color = .yellow }
        }
    }

    static func spawn(portal: SKSpriteNode) {
        let newArkon = Arkon(parentBiases: nil, parentWeights: nil)
        arkonHangar[newArkon.selectoid.fishNumber] = newArkon
        newArkon.sprite.position = portal.getRandomPoint()
        newArkon.sprite.zRotation = CGFloat.random(in: -CGFloat.pi..<CGFloat.pi)

//        newArkon.pBody.applyAngularImpulse(CGFloat(Int.random(in: -5..<5)))

        newArkon.contactDetector!.contactResponder =
            OmnivoresTestContactResponder(ownerArkon: newArkon)

        newArkon.contactDetector!.senseResponder = OmnivoresTestSenseResponder()

        onePass(sprite: newArkon.sprite, metabolism: newArkon.metabolism)
    }

    static func omnivoresTest(portal: SKSpriteNode) {
        for _ in 0..<100 { spawn(portal: portal) }
    }

    static func onePass(sprite thorax: SKSpriteNode, metabolism: Metabolism) {
        let nose = (thorax.children[0] as? Nose)!

        metabolism.oxygenLevel -= (4.0 / 60.0)
//        print("o2", thorax.arkon.selectoid.fishNumber, metabolism.oxygenLevel)

        guard metabolism.fungibleEnergyFullness > 0 && metabolism.oxygenLevel > 0 else {
            thorax.arkon.apoptosize()
            return
        }

        // 10% entropy
        let spawnCost = EnergyReserve.startingEnergyLevel * 1.10

        if metabolism.spawnReserves.level >= spawnCost {
            metabolism.withdrawFromSpawn(spawnCost)
            Arkon.spawn(portal: (thorax.parent as? SKSpriteNode)!)
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

        TheScene.netQueue.async(execute: workItem)
    }

    static func brainlyManeuverEnd(sprite thorax: SKSpriteNode, metabolism: Metabolism, motorOutputs: [Double]) {
        let maneuvers = Maneuvers(energySource: metabolism)
        let action = maneuvers.selectActionPrimitive(arkon: thorax, motorOutputs: motorOutputs)
        let wait = SKAction.wait(forDuration: 0.01)
        let sequence = SKAction.sequence([wait, action])
        thorax.run(sequence) { onePass(sprite: thorax, metabolism: metabolism) }
    }

    struct PreyTestContactResponder: ContactResponseProtocol {
        let ownerArkon: Arkon

        func respond(_ contactedBodies: [SKPhysicsBody]) {
            for body in contactedBodies where body.node is Thorax {
                let sprite = (body.node as? SKSpriteNode)!

                ownerArkon.metabolism.parasitize(sprite.arkon.metabolism)
            }
        }
    }

    struct PreyTestSenseResponder: SenseResponseProtocol {
        func respond(_ sensedBodies: [SKPhysicsBody]) {
            sensedBodies.forEach { ($0.node as? SKSpriteNode)?.color = .yellow }
        }
    }

    static func preyTest(portal: SKSpriteNode) {
        for a in 0..<100 {
            let newArkon = Arkon(parentBiases: nil, parentWeights: nil)
            arkonHangar[a] = newArkon
            newArkon.sprite.position = portal.getRandomPoint()

            if a > 0 { continue }

            newArkon.sprite.position = CGPoint.zero

            newArkon.contactDetector!.contactResponder =
                PreyTestContactResponder(ownerArkon: newArkon)

            newArkon.contactDetector!.senseResponder = PreyTestSenseResponder()

            onePass(sprite: newArkon.sprite, metabolism: newArkon.metabolism)
        }
    }
}
