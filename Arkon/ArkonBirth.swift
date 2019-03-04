import Foundation
import SpriteKit

extension Arkon {

    static private func attachSenses(_ sprite: SKSpriteNode, _ senses: SKPhysicsBody) {
        let snapPoint =
            Arkonery.shared.arkonsPortal.convert(sprite.position, to: Display.shared.scene!)

        let snap = SKPhysicsJointPin.joint(
            withBodyA: sprite.physicsBody!, bodyB: senses, anchor: snapPoint
        )

        Display.shared.scene!.physicsWorld.add(snap)
    }

    func launch(parentFishNumber: Int?) {
        self.sprite = setupSprites()
        self.motorOutputs = MotorOutputs(sprite)

        self.destructAction = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.sprite?.userData?["Arkon"] = nil
                self?.sprite = nil
            },
            SKAction.removeFromParent()
        ])

        self.tickAction = SKAction.run(
            { [weak self] in self?.tick() }, queue: World.shared.dispatchQueue
        )

        self.sprite.run(self.tickAction)

        // If I have a parent (ie, I'm not in the aboriginal generation), tell my
        // parent that my birth is complete, so she can get up and run away from
        // predators now.
        guard let p = parentFishNumber else { return }
        Arkonery.reviveSpawner(fishNumber: p)
    }

    func setupArkonSprite() -> (SKSpriteNode, SKPhysicsBody) {
        let arkonSprite = SKSpriteNode(texture: ArkonCentralLight.topTexture!)

        let x = Int.random(in: Int(-portal.frame.size.width)..<Int(portal.frame.size.width))
        let y = Int.random(in: Int(-portal.frame.size.height)..<Int(portal.frame.size.height))

        arkonSprite.position = CGPoint(x: x, y: y)
        arkonSprite.userData = ["Arkon": self]  // Ref to self; we're on our own after birth

        arkonSprite.size *= 0.2
        arkonSprite.color = ArkonCentralLight.colors.randomElement()!
        arkonSprite.colorBlendFactor = 0.5

        arkonSprite.zPosition = ArkonCentralLight.vArkonZPosition

        arkonSprite.name = "Arkon(\(fishNumber))"
        let physicsBody = Arkon.setupPhysicsBody()

        return (arkonSprite, physicsBody)
    }

    static func setupPhysicsBody() -> SKPhysicsBody {

        let pBody = SKPhysicsBody(circleOfRadius: 15.0)

        //        pBody.mass = 0.5

        pBody.categoryBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.collisionBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.fieldBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.contactTestBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue

        pBody.affectedByGravity = true
        pBody.isDynamic = true
        pBody.linearDamping = 1.0
        pBody.angularDamping = 1.0

        return pBody
    }

    static func setupSenses(_ arkonSprite: SKSpriteNode) -> (SKNode, SKPhysicsBody) {
        let sensesNode = SKSpriteNode(color: .clear, size: CGSize.zero)
        let sensesPhysicsBody = SKPhysicsBody(circleOfRadius: 30.0)

        sensesPhysicsBody.affectedByGravity = false
        sensesPhysicsBody.angularDamping = 0
        sensesPhysicsBody.isDynamic = true
        sensesPhysicsBody.linearDamping = 0
        sensesPhysicsBody.mass = 0

        sensesPhysicsBody.categoryBitMask = ArkonCentralLight.PhysicsBitmask.arkonSenses.rawValue

        // I want to sense arkons and food
        sensesPhysicsBody.contactTestBitMask =
            ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue |
            ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue

        // Senses aren't solid, and aren't affected by fields
        sensesPhysicsBody.collisionBitMask = 0
        sensesPhysicsBody.fieldBitMask = 0

        arkonSprite.addChild(sensesNode)

        return (sensesNode, sensesPhysicsBody)
    }

    func setupSprites() -> SKSpriteNode {
        let (arkonSprite, arkonPhysicsBody) = setupArkonSprite()
        let (sensesNode, sensesPhysicsBody) = Arkon.setupSenses(arkonSprite)

        portal.addChild(arkonSprite)

        sensesNode.physicsBody = sensesPhysicsBody
        arkonSprite.physicsBody = arkonPhysicsBody
        Arkon.attachSenses(arkonSprite, sensesPhysicsBody)

        return arkonSprite
   }

}
