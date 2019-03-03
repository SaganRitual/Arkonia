import Foundation
import SpriteKit

class MannaFactory {
    static var shared: MannaFactory!

    var morsels = [SKSpriteNode]()
    let xRange: Range<CGFloat>
    let yRange: Range<CGFloat>

    init() {
        let w = Arkonery.shared.arkonsPortal.frame.size.width
        let h = Arkonery.shared.arkonsPortal.frame.size.height

        xRange = -w..<w
        yRange = -h..<h
        morsels = (0..<200).map { spawn($0) }
    }

    func bloom(_ hamNumber: Int) {
        let sprite = morsels[hamNumber]
        sprite.position = CGPoint.random(x: xRange, y: yRange)

        sprite.alpha = 1.0
        sprite.physicsBody!.contactTestBitMask = ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue
    }

    func compost(_ sprite: SKSpriteNode) {
        sprite.alpha = 0.0
        sprite.physicsBody!.contactTestBitMask = 0

        let hamNumber = Int(sprite.name!)!
        sprite.run(SKAction.run(
            { [unowned self] in self.bloom(hamNumber) }, queue: World.shared.dispatchQueue
        ))
    }

    func setupPhysicsBody(_ edgeLoopFrame: CGRect) -> SKPhysicsBody {
        let p = SKPhysicsBody(edgeLoopFrom: edgeLoopFrame)

        p.categoryBitMask = ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue
        p.collisionBitMask = 0

        p.isDynamic = false

        return p
    }

    func spawn(_ hamNumber: Int) -> SKSpriteNode {
        let sprite = SKSpriteNode(texture: ArkonCentralLight.mannaSpriteTexture)

        sprite.setScale(0.025)
        sprite.color = .white
        sprite.colorBlendFactor = 0.5
        sprite.name = String(hamNumber)
        sprite.zPosition = ArkonCentralLight.vMannaZPosition

        sprite.physicsBody = setupPhysicsBody(sprite.frame)

        sprite.run(SKAction.run(
            { [unowned self] in self.bloom(hamNumber) }, queue: World.shared.dispatchQueue
        ))

        Arkonery.shared.arkonsPortal.addChild(sprite)

        return sprite
    }
}
