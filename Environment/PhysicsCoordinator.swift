import SpriteKit

protocol KPhysicsContactDelegate: class {
    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody])
}

enum PhysicsBitmask: UInt32 {
    case arkonBody = 0x01
    case arkonSenses = 0x02
    case mannaBody = 0x04
    case worldEdge = 0x08
}

class PhysicsCoordinator: NSObject, SKPhysicsContactDelegate {
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

        let node = hardBind(body.node as? KPhysicsContactDelegate)
//        let fn = (body.node as? Karamba)?.name ??
//                ((body.node as? Manna)?.name ??
//                ((body.node as? KNoseNode)?.name) ?? "goosle")
//        print("bottom, node \(fn) pushes \(body.allContactedBodies().count) bodies")
//        print("arkons: " +
//            "\(body.allContactedBodies().filter({ $0.node is Karamba }).count), " +
//            "manna: \(body.allContactedBodies().filter({ $0.node is Manna }).count)")
        node.pushContactedBodies(body.allContactedBodies())
    }
}
