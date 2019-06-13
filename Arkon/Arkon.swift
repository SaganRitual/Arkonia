import Foundation
import SpriteKit

struct Selectoid {
    static var TheFishNumber = 0

//    let birthday: TimeInterval
//    var cOffspring: Int
    let fishNumber: Int
//    let fishNumberOfParent: Int?
//    let genome: [GeneProtocol]
//    let genomeOfParent: [GeneProtocol]?

    init() {
        defer { Selectoid.TheFishNumber += 1 }
        fishNumber = Selectoid.TheFishNumber
    }
}

extension SKPhysicsBody: Massive {}

extension SKSpriteNode {
    var arkon: Arkon {
        get { return (userData!["arkon"] as? Arkon)! }
        set { userData!["arkon"] = newValue }
    }
}

class Arkon: HasContactDetector {
    var contactDetector: ContactDetectorProtocol?
    let metabolism: Metabolism
    let nose: SKSpriteNode
    var selectoid = Selectoid()
    var scene: SKSpriteNode { return Arkon.portal! }
    let sprite: SKSpriteNode
    var spriteFactory: SpriteFactory { return Arkon.spriteFactory! }

    init() {
        sprite = Arkon.spriteFactory!.arkonsHangar.makeSprite()
        sprite.setScale(0.5)
        sprite.color = .green
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
        nose.color = .magenta
        nose.colorBlendFactor = 1

        let nosePhysicsBody = SKPhysicsBody(circleOfRadius: nose.size.width)

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

    func tick() { metabolism.tick() }
}

extension Arkon {
    static var arkonHangar = [Int: Arkon]()
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
            let newArkon = Arkon()
            arkonHangar[a] = newArkon
            newArkon.sprite.position = CGPoint.zero

            newArkon.contactDetector!.contactResponder = ContactTestContactResponder()
            newArkon.contactDetector!.senseResponder = ContactTestSenseResponder()

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
            let newArkon = Arkon()
            arkonHangar[a] = newArkon
            newArkon.sprite.position = CGPoint.zero

            newArkon.contactDetector!.contactResponder =
                GrazeTestContactResponder(ownerArkon: newArkon)

            newArkon.contactDetector!.senseResponder = ContactTestSenseResponder()

            onePass(sprite: newArkon.sprite, metabolism: newArkon.metabolism)
        }
    }

    static func inject(_ spriteFactory: SpriteFactory, _ portal: SKSpriteNode) {
        Arkon.spriteFactory = spriteFactory
        Arkon.portal = portal
    }

    static func onePass(sprite: SKSpriteNode, metabolism: Metabolism) {
        let nose = (sprite.children[0] as? Nose)!
        nose.color = ColorGradient.makeColor(Int(metabolism.energyFullness * 100), 100)

        let maneuvers = Maneuvers(energySource: metabolism)
        let actions = getActions(sprite: sprite, maneuvers: maneuvers)

//        print("nass", sprite.physicsBody!.mass, metabolism.energyFullness)//, nosePhysicsBody.mass)

        sprite.run(actions) { onePass(sprite: sprite, metabolism: metabolism) }
    }
}
