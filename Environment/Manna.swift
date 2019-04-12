import Foundation
import SpriteKit

class Manna: SKSpriteNode, KPhysicsContactDelegate {
    var birthday: TimeInterval = 0
    let calories = 10
    var isComposting = false
    var isFirstBloom = true

    var foodValue: Double {
        get {
            let myAge = Display.shared.currentTime - birthday

            let baseValue = min(20.0, myAge)
            let adjustedValue = baseValue * (1 - World.shared.entropy)
            return adjustedValue
        }
    }

    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody]) {
//        let p = Display.displayCycle
//        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")
//
//        let k = hardBind(parent as? Karamba)
//        k.pushSensedBodies(contactedBodies)
    }

}

class MannaFactory {
    static var shared: MannaFactory!

    var morsels = [Manna]()
    let xRange: Range<CGFloat>
    let yRange: Range<CGFloat>

    init() {
        let w = PortalServer.shared.arkonsPortal.frame.size.width
        let h = PortalServer.shared.arkonsPortal.frame.size.height

        xRange = -w..<w
        yRange = -h..<h
        morsels = (0..<200).map { spawn($0) }
    }

    func bloom(_ hamNumber: Int) {
        let sprite = morsels[hamNumber]
        sprite.position = CGPoint.random(xRange: xRange, yRange: yRange)

        // Zero will make the manna worth extra, so the arkons won't starve
        // in the first five seconds.
        let birthday = sprite.isFirstBloom ? 0.0 : Display.shared.currentTime

        sprite.birthday = birthday
        sprite.isComposting = false
        sprite.colorBlendFactor = 1.0 - CGFloat(Display.shared.gameAge * 0.001)

        sprite.removeAllActions()
    }

    func compost(_ sprite: Manna) {
        sprite.isFirstBloom = false
        sprite.isComposting = true

        guard let name = sprite.name else { preconditionFailure() }
        guard var start = name.firstIndex(of: "_") else { preconditionFailure() }

        start = name.index(after: start)
        let hamNumber = Int(name[start..<name.endIndex])!

        let retain = hardBind(sprite.parent)
        let remove = SKAction.removeFromParent()
        let relax = SKAction.wait(forDuration: 2)
        let rebloom = SKAction.run { self.bloom(hamNumber) }
        let recycle = SKAction.sequence([remove, relax, rebloom])

        sprite.run(recycle, completion: { retain.addChild(sprite) })
    }

    func setupPhysicsBody(_ edgeLoopFrame: CGRect) -> SKPhysicsBody {
        let p = SKPhysicsBody(circleOfRadius: 1.0)

        p.categoryBitMask = ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue
        p.contactTestBitMask = 0
        p.collisionBitMask = 0

        return p
    }

    func spawn(_ hamNumber: Int) -> Manna {
        let sprite = Manna(texture: ArkonCentralLight.mannaSpriteTexture)

        sprite.setScale(0.03)
        sprite.color = .yellow
        sprite.colorBlendFactor = 1
        sprite.alpha = 1
        sprite.name = "manna_\(hamNumber)"
        sprite.zPosition = ArkonCentralLight.vMannaZPosition

        sprite.physicsBody = setupPhysicsBody(sprite.frame)
        sprite.isFirstBloom = true

        sprite.run(SKAction.run({ [unowned self] in self.bloom(hamNumber) }))

        PortalServer.shared.arkonsPortal.addChild(sprite)

        return sprite
    }
}
