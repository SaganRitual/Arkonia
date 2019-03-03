import Foundation
import SpriteKit

extension Arkon {

    func launch(parentFishNumber: Int?) {
        let sprite = Arkon.setupSprite(fishNumber)
        self.motorOutputs = MotorOutputs(sprite)

        self.sprite = sprite

        let x = Int.random(in: Int(-portal.frame.size.width)..<Int(portal.frame.size.width))
        let y = Int.random(in: Int(-portal.frame.size.height)..<Int(portal.frame.size.height))
        self.sprite.position = CGPoint(x: x, y: y)

        portal.addChild(sprite)

        self.sprite.userData = ["Arkon": self]  // Ref to self; we're on our own after birth

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

    static func setupSprite(_ fishNumber: Int) -> SKSpriteNode {
        let sprite = SKSpriteNode(texture: ArkonCentralLight.topTexture!)
        sprite.size *= 0.2
        sprite.color = ArkonCentralLight.colors.randomElement()!
        sprite.colorBlendFactor = 0.5

        sprite.zPosition = ArkonCentralLight.vArkonZPosition

        sprite.name = "\(fishNumber)"
        sprite.physicsBody = setupPhysicsBody()

        setupSenses(sprite)

        return sprite
    }

    static func setupPhysicsBody() -> SKPhysicsBody {

        let pBody = SKPhysicsBody(circleOfRadius: 15.0)

        //        pBody.mass = 0.5

        pBody.categoryBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.collisionBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.fieldBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.contactTestBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue

        //        pBody.friction = 1.0
        pBody.affectedByGravity = true
        pBody.isDynamic = true
        pBody.linearDamping = 1.0
        pBody.angularDamping = 1.0

        return pBody
    }

    static func setupSenses(_ sprite: SKSpriteNode) {
        let nose = SKNode()
        let senses = SKPhysicsBody(circleOfRadius: 30.0)

        senses.mass = 0
        senses.categoryBitMask = ArkonCentralLight.PhysicsBitmask.arkonSenses.rawValue

        // I want to sense arkons and food
        senses.contactTestBitMask =
            ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue |
            ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue

        // Senses aren't solid, and aren't affected by fields
        senses.collisionBitMask = 0
        senses.fieldBitMask = 0

        nose.physicsBody = senses
        sprite.addChild(nose)
    }

}
