import Foundation
import SpriteKit

class Physics: NSObject, SKPhysicsContactDelegate {
    override init() {
        super.init()

        Display.shared.scene!.physicsWorld.gravity = CGVector.zero
        Display.shared.scene!.physicsWorld.contactDelegate = self
    }

    func didBegin(_ contact: SKPhysicsContact) {

        let a = contact.bodyA
        let b = contact.bodyB

        if ((a.node?.alpha ?? 1) == 0) || ((b.node?.alpha ?? 1) == 0) { return }
        if a.node?.name == b.node?.name { print("here?"); return }

        let arkonSmellsFood =
            ArkonCentralLight.PhysicsBitmask.arkonSenses.rawValue |
                ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue

        let arkonTouchesFood =
            ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue |
                ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue

        let interaction = a.categoryBitMask | b.categoryBitMask

        switch interaction {
        case arkonSmellsFood:  Physics.senseFood(a, b)
        case arkonTouchesFood: Physics.touchFood(a, b)
        default: break
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        let a = contact.bodyA
        let b = contact.bodyB

        if ((a.node?.alpha ?? 1) == 0) || ((b.node?.alpha ?? 1) == 0) { return }
        if a.node?.name == b.node?.name { print("here?"); return }

        let arkonSmelledFood =
            ArkonCentralLight.PhysicsBitmask.arkonSenses.rawValue |
            ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue

        let interaction = a.categoryBitMask | b.categoryBitMask

        if interaction == arkonSmelledFood {
            Physics.loseTrackOfFood(a, b)
        }
    }
}

extension Physics {
    static private func assignSprites(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody)
        -> (SKSpriteNode?, SKSpriteNode?)
    {
        var arkonSprite: SKSpriteNode?
        var mannaSprite: SKSpriteNode?

        if bodyA.categoryBitMask == ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue {
            arkonSprite = bodyA.node as? SKSpriteNode
            mannaSprite = bodyB.node as? SKSpriteNode
        } else {
            arkonSprite = bodyB.node as? SKSpriteNode
            mannaSprite = bodyA.node as? SKSpriteNode
        }

        return (arkonSprite, mannaSprite)
    }

    static private func loseTrackOfFood(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) {
        guard case let (`as`?, ms?) = assignSprites(bodyA, bodyB) else { return }

        `as`.run(
            SKAction.run({ Arkon.loseTrackOfFood(`as`, ms) })
        )
    }

    static private func senseFood(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) {
        guard case let (`as`?, ms?) = assignSprites(bodyA, bodyB) else { return }

        `as`.run(
            SKAction.run({ Arkon.senseFood(`as`, ms) })
        )
    }

    static private func touchFood(_ bodyA: SKPhysicsBody, _ bodyB: SKPhysicsBody) {
        guard case let (`as`?, ms?) = assignSprites(bodyA, bodyB) else { return }

        `as`.run(
            SKAction.run({
                MannaFactory.shared.compost(ms)
                Arkon.absorbFood(`as`)
            })
        )
    }
}
