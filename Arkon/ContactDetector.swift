import SpriteKit

class ContactDetector: ContactDetectorProtocol, ContactCoordinatorDelegate {
    var contactedBodies: [SKPhysicsBody]?
    var contactResponder: ContactResponseProtocol?
    var isReadyForPhysics = false
    var sensedBodies: [SKPhysicsBody]?
    var senseResponder: SenseResponseProtocol?

    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody]) {
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")

        if !isReadyForPhysics { return }

        self.contactedBodies = contactedBodies.filter {
            $0.categoryBitMask == PhysicsBitmask.arkonBody.rawValue ||
            $0.categoryBitMask == PhysicsBitmask.mannaBody.rawValue
        }

        if let cb = self.contactedBodies, !cb.isEmpty, let cr = self.contactResponder {
            cr.respond(cb)
            return
        }

        self.contactedBodies = nil
    }

    func pushSensedBodies(_ sensedBodies: [SKPhysicsBody]) {
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")

        if !isReadyForPhysics { return }

        self.sensedBodies = sensedBodies.filter {
            $0.categoryBitMask == PhysicsBitmask.arkonBody.rawValue ||
            $0.categoryBitMask == PhysicsBitmask.mannaBody.rawValue
        }

        if let sb = self.sensedBodies, !sb.isEmpty, let sr = self.senseResponder {
            sr.respond(sb)
            return
        }

        self.sensedBodies = nil
    }

}
