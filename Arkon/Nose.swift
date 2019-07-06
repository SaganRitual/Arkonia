import SpriteKit

class Nose: SKSpriteNode, ContactCoordinatorDelegate {
    var ownerArkon: HasContactDetector {
        get {
            let key = SpriteUserDataKey.arkon
            return ((parent as? SKSpriteNode)!.userData?[key] as? HasContactDetector)! }
    }

    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody]) {
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")
        ownerArkon.contactDetector!.pushSensedBodies(contactedBodies)
    }
}

class Thorax: SKSpriteNode, ContactCoordinatorDelegate {
    var ownerArkon: HasContactDetector {
        get { return (userData?[SpriteUserDataKey.arkon] as? HasContactDetector)! }
    }

    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody]) {
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")
        ownerArkon.contactDetector!.pushContactedBodies(contactedBodies)
    }
}
