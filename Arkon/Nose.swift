import SpriteKit

class Nose: SKSpriteNode, ContactCoordinatorDelegate {
    var ownerArkon: HasContactDetector {
        get { return ((parent as? SKSpriteNode)!.userData?["arkon"] as? HasContactDetector)! }
    }

    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody]) {
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")
        ownerArkon.contactDetector!.pushSensedBodies(contactedBodies)
    }
}

class Thorax: SKSpriteNode, ContactCoordinatorDelegate {
    var ownerArkon: HasContactDetector {
        get { return (userData?["arkon"] as? HasContactDetector)! }
    }

    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody]) {
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")
        ownerArkon.contactDetector!.pushContactedBodies(contactedBodies)
    }
}
