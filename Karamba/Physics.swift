import SpriteKit

class KNoseNode: SKSpriteNode, KPhysicsContactDelegate {

    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody]) {
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")

        let k = hardBind(parent as? Karamba)
        k.pushSensedBodies(contactedBodies)
    }
}

extension Karamba: KPhysicsContactDelegate {

    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody]) {
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")

        if !readyForPhysics { return }

        self.contactedBodies = contactedBodies.filter {
            $0.categoryBitMask == PhysicsBitmask.arkonBody.rawValue
        }

        // If we're in contact with something we don't care about, such
        // as someone's sense ring, treat it as though we're not contacting
        // anyone.
        let c = hardBind(self.contactedBodies)
        if c.isEmpty { self.contactedBodies = nil }
    }

    func pushSensedBodies(_ sensedBodies: [SKPhysicsBody]) {
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")

        if !readyForPhysics { return }

        self.sensedBodies = sensedBodies.filter {
            $0.categoryBitMask == PhysicsBitmask.arkonBody.rawValue
        }

        // If we're in contact with something we don't care about, such
        // as someone's sense ring, treat it as though we're not contacting
        // anyone.
        let s = hardBind(self.sensedBodies)
        if s.isEmpty { self.sensedBodies = nil }
    }

}
