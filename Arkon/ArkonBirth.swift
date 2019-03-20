import Foundation
import SpriteKit

extension SKSpriteNode {
    var arkon: Arkon? {
        get { return getUserData(UserDataKey.arkon) }
        set { setUserData(key: UserDataKey.arkon, to: newValue) }
    }
}

extension Arkon {

    static private func attachSenses(_ sprite: SKSpriteNode, _ senses: SKPhysicsBody) {
        let snapPoint =
            PortalServer.shared.arkonsPortal.get().convert(sprite.position, to: Display.shared.scene!)

        let snap = SKPhysicsJointPin.joint(
            withBodyA: sprite.physicsBody!, bodyB: senses, anchor: snapPoint
        )

        Display.shared.scene!.physicsWorld.add(snap)
    }

    func launch() {
        self.sprite = setupSprites()
        self.motorOutputs = MotorOutputs(sprite)

        self.apoptosizeAction = SKAction.sequence([
            SKAction.run { [weak self] in
                self?.sprite.physicsBody = nil
                (self?.sprite.children[0] as? SKSpriteNode)?.physicsBody = nil
                self?.sprite?.userData?[SKSpriteNode.UserDataKey.arkon] = nil
            }, SKAction.removeFromParent()
        ])

        self.tickAction = SKAction.run(
            { [weak self] in self?.tick() }
        )

        postPartum(relievedArkonFishNumber: self.parentFishNumber)

        /*
         // So offspring won't come into existence on top of their
         // parent, which causes them to bounce around, which might
         // be ok, or not, I don't know. But when we run the following,
         // Everything gets really crazy, way more than without it.
         // Maybe we need to give the birthing mother a repeller field
         // to clear some space for her incoming baby. Come back to it.
         //
        if let parent = ArkonFactory.shared.getArkon(for: self.parentFishNumber) {
            let Θ = CGFloat.random(in: 0..<360)
            let r = 2.1 * sqrt(
                parent.sprite.frame.width * parent.sprite.frame.width +
                parent.sprite.frame.height * parent.sprite.frame.height
            )

            self.sprite.position = CGPoint(x: r * cos(Θ), y: r * sin(Θ))
        }
        */

        World.shared.populationChanged = true

        self.status.isAlive = true
        self.sprite.run(self.tickAction)
    }

    func postPartum(relievedArkonFishNumber: Int?) {
        guard let r = relievedArkonFishNumber else { return }
        guard let arkon = World.shared.population.getArkon(for: r) else { return }

        arkon.status.cOffspring += 1
        arkon.sprite.color = {
            switch arkon.status.cOffspring {
            case 0..<5: return .green
            case 5..<10: return .purple
            case 10..<15: return .magenta
            default: return .orange
            }
        }()

        arkon.sprite.color = arkon.status.cOffspring > 5 ? .purple : .green
        arkon.sprite.run(arkon.tickAction)
    }

    func setupArkonSprite() -> (SKSpriteNode, SKPhysicsBody) {
        let arkonSprite = SKSpriteNode(texture: ArkonCentralLight.topTexture!)

        let x = Int.random(in: Int(-portal.frame.size.width)..<Int(portal.frame.size.width))
        let y = Int.random(in: Int(-portal.frame.size.height)..<Int(portal.frame.size.height))

        arkonSprite.position = CGPoint(x: x, y: y)
        arkonSprite.size *= 0.2
        arkonSprite.color = .green//ArkonCentralLight.colors.randomElement()!
        arkonSprite.colorBlendFactor = 0.5

        arkonSprite.zPosition = ArkonCentralLight.vArkonZPosition

        arkonSprite.name = "arkon_\(fishNumber)"
        let physicsBody = Arkon.setupPhysicsBody(arkonSprite.frame.size)

        return (arkonSprite, physicsBody)
    }

    static func setupPhysicsBody(_ size: CGSize) -> SKPhysicsBody {
        let pBodyRadius = size.width / 2
        let pBody = SKPhysicsBody(circleOfRadius: pBodyRadius)

//        pBody.mass = 1.0

        pBody.categoryBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.collisionBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.contactTestBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.fieldBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue

        pBody.affectedByGravity = false
//        pBody.allowsRotation = false
        pBody.isDynamic = true
//        pBody.linearDamping = 0
//        pBody.angularDamping = 0
//        pBody.friction = 0
//        pBody.restitution = 0

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

        sensesPhysicsBody.contactTestBitMask =
            ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue |
            ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue

        sensesPhysicsBody.collisionBitMask = 0
        sensesPhysicsBody.fieldBitMask = 0

        arkonSprite.addChild(sensesNode)

        return (sensesNode, sensesPhysicsBody)
    }

    func setupSprites() -> SKSpriteNode {
        let (arkonSprite, arkonPhysicsBody) = setupArkonSprite()
        let (sensesNode, sensesPhysicsBody) = Arkon.setupSenses(arkonSprite)

        if arkonSprite.userData == nil { arkonSprite.userData = [:] }
        arkonSprite.userData![SKSpriteNode.UserDataKey.arkon] = self // Ref to self; we're on our own after birth

        portal.addChild(arkonSprite)

        sensesNode.physicsBody = sensesPhysicsBody
        arkonSprite.physicsBody = arkonPhysicsBody
        Arkon.attachSenses(arkonSprite, sensesPhysicsBody)

        return arkonSprite
   }

}
