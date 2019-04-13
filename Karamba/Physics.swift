import SpriteKit

class KNoseNode: SKSpriteNode, KPhysicsContactDelegate {

    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody]) {
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")

        let k = hardBind(parent as? Karamba)
        k.pushSensedBodies(contactedBodies)
//        print("nose \(k.scab.fishNumber) senses \(contactedBodies.count) bodies")
    }
}

extension Karamba: KPhysicsContactDelegate {

    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody]) {
//        print("pcb \(scab.fishNumber)", terminator: "")
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")

        if !readyForPhysics { return }

        self.contactedBodies = contactedBodies.filter {
            $0.categoryBitMask == PhysicsBitmask.arkonBody.rawValue ||
            $0.categoryBitMask == PhysicsBitmask.mannaBody.rawValue
        }

        let c = hardBind(self.contactedBodies)
        if c.isEmpty { self.contactedBodies = nil }
//        print(" contacts \(c.count) bodies from \(contactedBodies.count)")
    }

    func pushSensedBodies(_ sensedBodies: [SKPhysicsBody]) {
//        print("psb \(scab.fishNumber)", terminator: "")
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")

        if !readyForPhysics { return }

        self.sensedBodies = sensedBodies.filter {
            $0.categoryBitMask == PhysicsBitmask.arkonBody.rawValue ||
            $0.categoryBitMask == PhysicsBitmask.mannaBody.rawValue
        }

        let s = hardBind(self.sensedBodies)
        if s.isEmpty { self.sensedBodies = nil }
//        print(" senses \(s.count) bodies from \(s.count)")
    }

}
