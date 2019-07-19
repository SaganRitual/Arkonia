import SpriteKit

class ContactResponder: ContactResponseProtocol {
    weak var ownerKaramba: Karamba!
    var processingTouch = false

    init(ownerKaramba: Karamba) { self.ownerKaramba = ownerKaramba }

    func respond(_ contactedBodies: [SKPhysicsBody]) {
        for body in contactedBodies {
            switch body.node {
            case let t as Thorax:
                if touchArkon(t) {
                    return
                }

            case let m as SKSpriteNode:
                touchManna(m.manna)
                return

            default: assert(false)
            }
        }
    }

    func touchArkon(_ thorax: Thorax) -> Bool {
        if processingTouch { return false }
        processingTouch = true
        defer { processingTouch = false }

//            if thorax.arkon.selectoid.fishNumber < ownerArkon.selectoid.fishNumber {
//                ownerArkon.metabolism.parasitize(thorax.arkon.metabolism)
//                return true
//            }

        return false
    }

    func touchManna(_ manna: Manna) {
        if processingTouch { return }
        processingTouch = true
        defer { processingTouch = false }

        let sprite = manna.sprite
        let background = (sprite.parent as? SKSpriteNode)!

        let harvested = sprite.manna.harvest()
        ownerKaramba.metabolism.absorbEnergy(harvested)

        let actions = Manna.triggerDeathCycle(sprite: sprite, background: background)
        sprite.run(actions)
    }
}
