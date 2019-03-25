import Foundation
import SpriteKit

class MannaFactory {
    static var shared: MannaFactory!

    var morsels = [SKSpriteNode]()
    let xRange: Range<CGFloat>
    let yRange: Range<CGFloat>

    init() {
        let w = PortalServer.shared.arkonsPortal.get().frame.size.width
        let h = PortalServer.shared.arkonsPortal.get().frame.size.height

        xRange = -w..<w
        yRange = -h..<h
        morsels = (0..<200).map { spawn($0) }
    }

    func bloom(_ hamNumber: Int) {
        let sprite = morsels[hamNumber]
        sprite.position = CGPoint.random(xRange: xRange, yRange: yRange)

        // Zero will make the manna worth extra, so the arkons won't starve
        // in the first five seconds.
        let birthday = (sprite.isFirstBloom ?? false) ? 0.0 : Display.shared.currentTime

        sprite.birthday = birthday
        sprite.isComposting = false
        sprite.colorBlendFactor = 1.0 - CGFloat(Display.shared.gameAge * 0.001)

        sprite.removeAllActions()
        sprite.physicsBody!.contactTestBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
    }

    func compost(_ sprite: SKSpriteNode) {
        sprite.physicsBody!.contactTestBitMask = 0

        sprite.isFirstBloom = false
        sprite.isComposting = true

        guard let name = sprite.name else { preconditionFailure() }
        guard var start = name.firstIndex(of: "_") else { preconditionFailure() }

        start = name.index(after: start)
        let hamNumber = Int(name[start..<name.endIndex])!
        sprite.run(SKAction.run(
            { [unowned self] in self.bloom(hamNumber) }
        ))
    }

    func setupPhysicsBody(_ edgeLoopFrame: CGRect) -> SKPhysicsBody {
        let p = SKPhysicsBody(circleOfRadius: 1.0)

        p.categoryBitMask = ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue
        p.contactTestBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
        p.collisionBitMask = 0

        p.isDynamic = false

        return p
    }

    func spawn(_ hamNumber: Int) -> SKSpriteNode {
        let sprite = SKSpriteNode(texture: ArkonCentralLight.mannaSpriteTexture)

        sprite.setScale(0.03)
        sprite.color = .yellow
        sprite.colorBlendFactor = 1
        sprite.alpha = 1
        sprite.name = "manna_\(hamNumber)"
        sprite.zPosition = ArkonCentralLight.vMannaZPosition

        sprite.physicsBody = setupPhysicsBody(sprite.frame)

        sprite.setupAsManna()
        sprite.isFirstBloom = true

        sprite.run(SKAction.run({ [unowned self] in self.bloom(hamNumber) }))

        PortalServer.shared.arkonsPortal.get().addChild(sprite)

        return sprite
    }
}

extension SKSpriteNode {
    func setupAsManna() {
        self.birthday = 0.0
        self.isComposting = false
        self.isFirstBloom = true
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
            let adjustedValue = baseValue * (1 - World.shared.entropy)
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
}
