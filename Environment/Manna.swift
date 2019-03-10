import Foundation
import SpriteKit

class MannaFactory {
    static var shared: MannaFactory!

    var morsels = [SKSpriteNode]()
    let xRange: Range<CGFloat>
    let yRange: Range<CGFloat>

    init() {
        let w = ArkonFactory.shared.arkonsPortal.frame.size.width
        let h = ArkonFactory.shared.arkonsPortal.frame.size.height

        xRange = -w..<w
        yRange = -h..<h
        morsels = (0..<200).map { spawn($0) }
    }

    func bloom(_ hamNumber: Int) {
        let sprite = morsels[hamNumber]
        sprite.position = CGPoint.random(x: xRange, y: yRange)

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
        guard var start = name.firstIndex(of: "(") else { preconditionFailure() }
        guard let end = name.firstIndex(of: ")") else { preconditionFailure() }

        start = name.index(after: start)
        let hamNumber = Int(name[start..<end])!
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
        sprite.name = "Manna(\(hamNumber))"
        sprite.zPosition = ArkonCentralLight.vMannaZPosition

        sprite.physicsBody = setupPhysicsBody(sprite.frame)

        sprite.setupAsManna()
        sprite.isFirstBloom = true

        sprite.run(SKAction.run({ [unowned self] in self.bloom(hamNumber) }))

        ArkonFactory.shared.arkonsPortal.addChild(sprite)

        return sprite
    }
}
