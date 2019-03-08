import Foundation
import SpriteKit

extension SKSpriteNode {
    enum UserDataKey {
        case arkon, birthday, isAwaitingNextPhysicsCycle, isComposting, isFirstBloom
    }

    func getUserData<T>(_ key: UserDataKey) -> T? {
        guard let userData = self.userData else { return nil }
        guard let itemEntry = userData[key] else { return nil }
        return itemEntry as? T
    }

    func setupAsArkon() {
        self.isAwaitingNextPhysicsCycle = false
    }

    func setupAsManna() {
        self.birthday = 0.0
        self.isComposting = false
        self.isFirstBloom = true
        self.isAwaitingNextPhysicsCycle = false
    }

    func setUserData<T>(key: UserDataKey, to value: T?) {
        if self.userData == nil { self.userData = [:] }
//        print("pud", key, value!, userData == nil, userData?[key] == nil, value!)
        self.userData?[key] = value
//        print("sud", key, value!, userData == nil, userData?[key] == nil, value!)
    }

    var arkon: Arkon? {
        get { return getUserData(UserDataKey.arkon) }
        set { setUserData(key: UserDataKey.arkon, to: newValue) }
    }

    var birthday: TimeInterval? {
        get { return getUserData(UserDataKey.birthday) }
        set { setUserData(key: UserDataKey.birthday, to: newValue) }
    }

    var isComposting: Bool? {
        get { return getUserData(UserDataKey.isComposting) }
        set { setUserData(key: UserDataKey.isComposting, to: newValue) }
    }

    var isFirstBloom: Bool? {
        get { return getUserData(UserDataKey.isFirstBloom) }
        set { setUserData(key: UserDataKey.isFirstBloom, to: newValue) }
    }

    var isAwaitingNextPhysicsCycle: Bool? {
        get {
//            print("get", getUserData(UserDataKey.isAwaitingNextPhysicsCycle) ?? false)
            return getUserData(UserDataKey.isAwaitingNextPhysicsCycle)
        }
        set {
//            print("set", getUserData(UserDataKey.isAwaitingNextPhysicsCycle) ?? false)
//            defer { print("set2", getUserData(UserDataKey.isAwaitingNextPhysicsCycle) ?? false) }
            setUserData(key: UserDataKey.isAwaitingNextPhysicsCycle, to: newValue)
        }
    }
}

extension Arkon {

    static private func attachSenses(_ sprite: SKSpriteNode, _ senses: SKPhysicsBody) {
        let snapPoint =
            Arkonery.shared.arkonsPortal.convert(sprite.position, to: Display.shared.scene!)

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

        Arkonery.shared.cLivingArkons += 1

        self.isAlive = true
        self.sprite.run(self.tickAction)
    }

    func postPartum(relievedArkonFishNumber: Int?) {
        guard let r = relievedArkonFishNumber else { return }
        guard let arkon = Arkonery.shared.getArkon(for: r) else { return }
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
        let physicsBody = Arkon.setupPhysicsBody()

        return (arkonSprite, physicsBody)
    }

    static func setupPhysicsBody() -> SKPhysicsBody {

        let pBody = SKPhysicsBody(circleOfRadius: 15.0)

//        pBody.mass = 1.0

        pBody.categoryBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.collisionBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.contactTestBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        pBody.fieldBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue

        pBody.affectedByGravity = true
        pBody.isDynamic = true
        pBody.linearDamping = 2.0
        pBody.angularDamping = 2.0
        pBody.friction = 2.0
        pBody.restitution = 0

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