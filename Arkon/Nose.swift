import SpriteKit

class Nose: SKSpriteNode, ContactCoordinatorDelegate {
    var ownerArkon: Arkon {
        get { return (parent as? SKSpriteNode)!.arkon }
    }

    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody]) {
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")
        ownerArkon.contactDetector.pushSensedBodies(contactedBodies)
    }
}

class Thorax: SKSpriteNode, ContactCoordinatorDelegate {
    var ownerArkon: Arkon {
        get { return arkon }
    }

    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody]) {
        let p = Display.displayCycle
        assert(p.isIn(.physics), "Call this function only in physics phase: \(p)")
        ownerArkon.contactDetector.pushContactedBodies(contactedBodies)
    }
}
