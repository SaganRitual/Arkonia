import SpriteKit

protocol ContactCoordinatorDelegate: class {
    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody])
}

enum PhysicsBitmask: UInt32 {
    case arkonBody = 0x01
    case arkonSenses = 0x02
    case mannaBody = 0x04
    case worldEdge = 0x08
}

class ContactCoordinator: NSObject, SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        pushContactedBodies(contact.bodyA)
        pushContactedBodies(contact.bodyB)
    }

    func didEnd(_ contact: SKPhysicsContact) {
        pushContactedBodies(contact.bodyA)
        pushContactedBodies(contact.bodyB)
    }

    private func pushContactedBodies(_ body: SKPhysicsBody) {
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")

        if let node = body.node as? ContactCoordinatorDelegate {
            node.pushContactedBodies(body.allContactedBodies())
            return
        }
    }
}
