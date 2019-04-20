import Foundation
import SpriteKit

class Manna: SKSpriteNode {
    var birthday: TimeInterval = 0
    var isComposting = false
    var isFirstBloom = true
    let mass = 0.5 * ArkonFactory.scale
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
        morsels = (0..<300).map { [weak self] in self!.spawn($0) }
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
    }

    func compost(_ sprite: Manna) {
        sprite.isFirstBloom = false
        sprite.isComposting = true

        guard let name = sprite.name else { preconditionFailure() }
        guard var start = name.firstIndex(of: "_") else { preconditionFailure() }

        start = name.index(after: start)
        let hamNumber = Int(name[start..<name.endIndex])!

        let remove = SKAction.run { sprite.alpha = 0 }
        let relax = SKAction.wait(forDuration: 2)
        let rebloom = SKAction.run { self.bloom(hamNumber) }
        let recycle = SKAction.sequence([remove, relax, rebloom])

        sprite.run(recycle, completion: { sprite.alpha = 1 })
    }

    func setupPhysicsBody(_ edgeLoopFrame: CGRect) -> SKPhysicsBody {
        let p = SKPhysicsBody(circleOfRadius: 1.0)

        p.categoryBitMask = ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue
        p.contactTestBitMask = 0
        p.collisionBitMask = 0
        p.pinned = true
        p.isDynamic = false
        p.mass = 1
        p.allowsRotation = false

        return p
    }

    func spawn(_ hamNumber: Int) -> Manna {
//        print("spawn", Display.displayCycle)
        let sprite = Manna(texture: ArkonCentralLight.mannaSpriteTexture)

        sprite.setScale(0.03)
        sprite.color = .yellow
        sprite.colorBlendFactor = 1
        sprite.alpha = 1
        sprite.name = "manna_\(hamNumber)"
//        print("name = ", sprite.name!)
        sprite.zPosition = ArkonCentralLight.vMannaZPosition

        sprite.isFirstBloom = true

        sprite.run(SKAction.run({ [unowned self] in self.bloom(hamNumber) }))

        PortalServer.shared.arkonsPortal.addChild(sprite)
        sprite.physicsBody = setupPhysicsBody(sprite.frame)

        return sprite
    }
}
