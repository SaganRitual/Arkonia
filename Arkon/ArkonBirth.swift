import Foundation
import SpriteKit

extension SKSpriteNode {
    enum UserDataKey {
        case arkon, birthday, foodValue, isComposting, isFirstBloom, isOldestArkon
    }

    func getUserData<T>(_ key: UserDataKey) -> T? {
        guard let userData = self.userData else { return nil }
        guard let itemEntry = userData[key] else { return nil }
        return itemEntry as? T
    }

    func setupAsArkon() {
    }

    func setupAsManna() {
        self.birthday = 0.0
        self.isComposting = false
        self.isFirstBloom = true
    }

    func setUserData<T>(key: UserDataKey, to value: T?) {
        if self.userData == nil { self.userData = [:] }
        self.userData?[key] = value
    }

    var arkon: Arkon? {
        get { return getUserData(UserDataKey.arkon) }
        set { setUserData(key: UserDataKey.arkon, to: newValue) }
    }

    var birthday: TimeInterval? {
        get { return getUserData(UserDataKey.birthday) }
        set { setUserData(key: UserDataKey.birthday, to: newValue) }
    }

    var foodValue: Double {
        get {
            guard let birthday = self.birthday else { return 10 }
            let myAge = Display.shared.currentTime - birthday

            let baseValue = min(20.0, myAge)
            let adjustedValue = baseValue * World.shared.foodValue
            return adjustedValue
        }
    }

    var isComposting: Bool? {
        get { return getUserData(UserDataKey.isComposting) }
        set { setUserData(key: UserDataKey.isComposting, to: newValue) }
    }

    var isFirstBloom: Bool? {
        get { return getUserData(UserDataKey.isFirstBloom) }
        set { setUserData(key: UserDataKey.isFirstBloom, to: newValue) }
    }

    var isOldestArkon: Bool? {
        get { return getUserData(UserDataKey.isOldestArkon) }
        set { setUserData(key: UserDataKey.isOldestArkon, to: newValue) }
    }
}

extension Arkon {

    static private func attachSenses(_ sprite: SKSpriteNode, _ senses: SKPhysicsBody) {
        let snapPoint =
            PortalServer.shared.arkonsPortal.convert(sprite.position, to: Display.shared.scene!)

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
                self?.sprite?.arkon = nil
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

        ArkonFactory.shared.cLiveArkons += 1

        self.isAlive = true
        self.sprite.run(self.tickAction)
    }

    func postPartum(relievedArkonFishNumber: Int?) {
        guard let r = relievedArkonFishNumber else { return }
        guard let arkon = ArkonFactory.shared.getArkon(for: r) else { return }
        arkon.cOffspring += 1
        arkon.sprite.color = .green
        arkon.sprite.run(arkon.tickAction)
    }

    func setupArkonSprite() -> (SKSpriteNode, SKPhysicsBody) {
        let arkonSprite = SKSpriteNode(texture: ArkonCentralLight.topTexture!)
        arkonSprite.setupAsArkon()

        let x = Int.random(in: Int(-portal.frame.size.width)..<Int(portal.frame.size.width))
        let y = Int.random(in: Int(-portal.frame.size.height)..<Int(portal.frame.size.height))

        arkonSprite.position = CGPoint(x: x, y: y)
        arkonSprite.arkon = self // Ref to self; we're on our own after birth

        arkonSprite.size *= 0.2
        arkonSprite.color = .green//ArkonCentralLight.colors.randomElement()!
        arkonSprite.colorBlendFactor = 0.5

        arkonSprite.zPosition = ArkonCentralLight.vArkonZPosition

        arkonSprite.name = "Arkon(\(fishNumber))"
        let physicsBody = Arkon.setupPhysicsBody(arkonSprite.frame.size)

        return (arkonSprite, physicsBody)
    }

    static func setupPhysicsBody(_ size: CGSize) -> SKPhysicsBody {
        let pBodyRadius = sqrt(size.width * size.width + size.height * size.height) / 2
        let pBody = SKPhysicsBody(circleOfRadius: pBodyRadius)

//        pBody.mass = 1.0

        pBody.categoryBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.collisionBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.contactTestBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.fieldBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue

        pBody.affectedByGravity = true
        pBody.isDynamic = true
        pBody.linearDamping = 2
        pBody.angularDamping = 2
        pBody.friction = 2
        pBody.restitution = 1

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

        arkonSprite.arkon = self
        portal.addChild(arkonSprite)

        sensesNode.physicsBody = sensesPhysicsBody
        arkonSprite.physicsBody = arkonPhysicsBody
        Arkon.attachSenses(arkonSprite, sensesPhysicsBody)

        return arkonSprite
   }

}
