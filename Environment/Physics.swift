import Foundation
import SpriteKit

class Physics: NSObject, SKPhysicsContactDelegate {
    override init() {
        super.init()

        Display.shared.scene!.physicsWorld.gravity = CGVector.zero
    }
}

extension Physics {

    static let arkonSmellsFood =
        ArkonCentralLight.PhysicsBitmask.arkonSenses.rawValue |
            ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue

    static let arkonIsTouchingFood =
        ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue |
            ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue

    private func getContactInfo(_ contact: SKPhysicsContact) -> UInt32? {
        let nodeA = ?!contact.bodyA.node
        let nodeB = ?!contact.bodyB.node

        let spriteA_ = nodeA as? SKSpriteNode
        let spriteB_ = nodeB as? SKSpriteNode

        // Because the physics engine gets cranky if we try to add physics
        // bodies to our nodes before we add the nodes to the scene, we have
        // to allow for physics interactions before we're fully ready
        // (that is, before we've added the physics bodies). So don't do anything
        // until isAlive is set.
        if !(((spriteA_ as? Karamba)?.scab.status.isAlive) ?? true) { return nil }
        if !(((spriteB_ as? Karamba)?.scab.status.isAlive) ?? true) { return nil }

        if (spriteA_?.isComposting ?? false) || (spriteB_?.isComposting ?? false) { return nil }

        return contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let interaction = getContactInfo(contact) else { return }

        let nodeA = ?!contact.bodyA.node
        let nodeB = ?!contact.bodyB.node

        if (interaction & Physics.arkonSmellsFood) == Physics.arkonSmellsFood {
            guard case let (arkonSprite?, mannaSprite?) =
                Physics.assignSprites(nodeA, nodeB) else { return }

            guard let arkon = arkonSprite.arkon else { return }
            arkon.sensedBodies = Physics.senseFood(arkonSprite, mannaSprite)
        }

        if (interaction & Physics.arkonIsTouchingFood) == Physics.arkonIsTouchingFood {
            guard case let (arkonSprite?, mannaSprite?) =
                Physics.assignSprites(nodeA, nodeB) else { return }

            guard let arkon = arkonSprite.arkon else { return }
            arkon.contactedBodies = Physics.touchFood(arkonSprite, mannaSprite)
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        guard let interaction = getContactInfo(contact) else { return }

        let nodeA = ?!contact.bodyA.node
        let nodeB = ?!contact.bodyB.node

        if (interaction & Physics.arkonSmellsFood) == Physics.arkonSmellsFood {
            guard case let (arkonSprite?, mannaSprite?) =
                Physics.assignSprites(nodeA, nodeB) else { return }

            guard let arkon = arkonSprite.arkon else { return }
            arkon.sensedBodies = Physics.loseTrackOfFood(arkonSprite, mannaSprite)
        }
    }
}

extension Physics {
    static private func assignSprites(_ a: SKNode, _ b: SKNode)
        -> (Karamba?, SKSpriteNode?)
    {
        var arkonSprite: Karamba?
        var mannaSprite: SKSpriteNode?

        // It seems that we can come in here after the sprite invovled in the
        // interaction has destructed. Not sure whether It's normal, or a sign of
        // a bug in my code. I'll come to it after I get some gratification.
        guard let aPhysics = a.physicsBody, let bPhysics = b.physicsBody else { return (nil, nil) }

        if aPhysics.categoryBitMask == ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue {
            arkonSprite = a as? Karamba
        } else if aPhysics.categoryBitMask == ArkonCentralLight.PhysicsBitmask.arkonSenses.rawValue {
            arkonSprite = a.parent as? Karamba
        } else if aPhysics.categoryBitMask == ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue {
            mannaSprite = a as? SKSpriteNode
        }

        if bPhysics.categoryBitMask == ArkonCentralLight.PhysicsBitmask.mannaBody.rawValue {
            mannaSprite = b as? SKSpriteNode
        } else if bPhysics.categoryBitMask == ArkonCentralLight.PhysicsBitmask.arkonSenses.rawValue {
            arkonSprite = b.parent as? Karamba
        } else if bPhysics.categoryBitMask == ArkonCentralLight.PhysicsBitmask.arkonBody.rawValue {
            arkonSprite = b as? Karamba
        }

        if arkonSprite == nil || mannaSprite == nil { return (nil, nil) }

        if mannaSprite?.isComposting ?? false { return (nil, nil) }

        return (arkonSprite, mannaSprite)
    }

    static private func loseTrackOfFood(_ a: SKNode, _ b: SKNode) -> [SKPhysicsBody] {
        guard case let (arkonSprite?, _?) = assignSprites(a, b) else { return [] }
        guard let pBody = arkonSprite.physicsBody else { return [] }

        return pBody.allContactedBodies()
    }

    static private func senseFood(_ a: SKNode, _ b: SKNode) -> [SKPhysicsBody] {
        guard case let (arkonSprite?, _?) = assignSprites(a, b) else { return [] }
        guard let pBody = arkonSprite.physicsBody else { return [] }

        return pBody.allContactedBodies()
    }

    static private func touchFood(_ a: SKNode, _ b: SKNode) -> [SKPhysicsBody] {
        guard case let (arkonSprite?, mannaSprite?) = assignSprites(a, b) else { return [] }
        MannaFactory.shared.compost(mannaSprite)

        guard let pBody = arkonSprite.physicsBody else { return [] }
        return pBody.allContactedBodies()
    }
}
