import Foundation
import SpriteKit

class Physics: NSObject, SKPhysicsContactDelegate {
    override init() {
        super.init()

        Display.shared.scene!.physicsWorld.gravity = CGVector.zero
    }

    func didBegin(_ contact: SKPhysicsContact) {

        guard let a = contact.bodyA.node as? SKSpriteNode else { return }
        guard let b = contact.bodyB.node as? SKSpriteNode else { return }

        if (a.isComposting ?? false) || (b.isComposting ?? false) { return }

        let arkonSmellsFood =
            ArkonCentralLight.PhysicsBitmask.arkonSenses.rawValue |
                ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue

        let arkonTouchesFood =
            ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue |
                ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue

        let interaction = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if (interaction & arkonSmellsFood) == arkonSmellsFood { Physics.senseFood(a, b) }
        if (interaction & arkonTouchesFood) == arkonTouchesFood { Physics.touchFood(a, b); return }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        guard let a = contact.bodyA.node as? SKSpriteNode else { return }
        guard let b = contact.bodyB.node as? SKSpriteNode else { return }

        if (a.isComposting ?? false) || (b.isComposting ?? false) { return }

        let arkonSmelledFood =
            ArkonCentralLight.PhysicsBitmask.arkonSenses.rawValue |
            ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue

        let interaction = a.physicsBody!.categoryBitMask | b.physicsBody!.categoryBitMask

        if (interaction & arkonSmelledFood) == arkonSmelledFood { Physics.loseTrackOfFood(a, b) }
    }
}

extension Physics {
    static private func assignSprites(_ a: SKSpriteNode, _ b: SKSpriteNode)
        -> (SKSpriteNode?, SKSpriteNode?)
    {
        var arkonSprite: SKSpriteNode?
        var mannaSprite: SKSpriteNode?

        guard let aPhysics = a.physicsBody, let bPhysics = b.physicsBody else { preconditionFailure() }

        if aPhysics.categoryBitMask == ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue {
            arkonSprite = a
        } else if aPhysics.categoryBitMask == ArkonCentralLight.PhysicsBitmask.arkonSenses.rawValue {
            arkonSprite = a.parent as? SKSpriteNode
        } else if aPhysics.categoryBitMask == ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue {
            mannaSprite = a
        }

        if bPhysics.categoryBitMask == ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue {
            mannaSprite = b
        } else if bPhysics.categoryBitMask == ArkonCentralLight.PhysicsBitmask.arkonSenses.rawValue {
            arkonSprite = b.parent as? SKSpriteNode
        } else if bPhysics.categoryBitMask == ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue {
            arkonSprite = b
        }

        if arkonSprite == nil || mannaSprite == nil { return (nil, nil) }

        if mannaSprite?.isComposting ?? false { return (nil, nil) }

        return (arkonSprite, mannaSprite)
    }

    static private func loseTrackOfFood(_ a: SKSpriteNode, _ b: SKSpriteNode) {
        guard case let (`as`?, ms?) = assignSprites(a, b) else { return }

        `as`.run(
            SKAction.run({ Arkon.loseTrackOfFood(`as`, ms) })
        )
    }

    static private func senseFood(_ a: SKSpriteNode, _ b: SKSpriteNode) {
        guard case let (`as`?, ms?) = assignSprites(a, b) else { return }

        `as`.run(
            SKAction.run({ Arkon.senseFood(`as`, ms) })
        )
    }

    static private func touchFood(_ a: SKSpriteNode, _ b: SKSpriteNode) {
        guard case let (`as`?, ms?) = assignSprites(a, b) else { return }

        `as`.run(SKAction.run({ Arkon.absorbFood(`as`, ms) }))
    }
}
