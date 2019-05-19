import Foundation
import SpriteKit

struct Selectoid {
    let birthday: TimeInterval
    var cOffspring: Int
    let fishNumber: Int
    let fishNumberOfParent: Int?
    let genome: [GeneProtocol]
    let genomeOfParent: [GeneProtocol]?
}

class Arkon {
//    var selectoid: Selectoid
    var scene: SKSpriteNode { return Arkon.portal! }
    let sprite: SKSpriteNode
    var spriteFactory: SpriteFactory { return Arkon.spriteFactory! }

    init() {
        sprite = Arkon.spriteFactory!.arkonsHangar.makeSprite()
        sprite.color = .green
        sprite.colorBlendFactor = 1
        scene.addChild(sprite)
    }
}

extension Arkon {
    static var portal: SKSpriteNode?
    static var spriteFactory: SpriteFactory?

    static func inject(_ spriteFactory: SpriteFactory, _ portal: SKSpriteNode) {
        Arkon.spriteFactory = spriteFactory
        Arkon.portal = portal
    }
}
