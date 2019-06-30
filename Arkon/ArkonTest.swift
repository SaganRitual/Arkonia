import SpriteKIt

extension Arkon {
    static func getActions(sprite: SKSpriteNode, maneuvers: Maneuvers) -> SKAction {
        let actions = SKAction.sequence([
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 1, 0, 0]),  // thrust
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [0.5, 0, 0, 0, 1]),  // wait
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 1, 0, 0, 0]),  // stop
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [0.5, 0, 0, 0, 1]),  // wait
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 0, 1, 0]),  // rotate
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [0.5, 0, 0, 0, 1]),  // wait
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 1, 0, 0, 0]),  // stop
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [0.5, 0, 0, 0, 1])  // wait
            ])

        return actions
    }

    struct ContactTestContactResponder: ContactResponseProtocol {
        func respond(_ contactedBodies: [SKPhysicsBody]) {
            contactedBodies.forEach { ($0.node as? SKSpriteNode)?.color = .blue }
        }
    }

    struct ContactTestSenseResponder: SenseResponseProtocol {
        func respond(_ sensedBodies: [SKPhysicsBody]) {
            sensedBodies.forEach { ($0.node as? SKSpriteNode)?.color = .yellow }
        }
    }

    static func contactTest() {
        for a in 0..<1 {
            let newArkon = Arkon(parentBiases: nil, parentWeights: nil)
            arkonHangar[a] = newArkon
            newArkon.sprite.position = CGPoint.zero

            newArkon.contactDetector!.contactResponder = ContactTestContactResponder()
            newArkon.contactDetector!.senseResponder = ContactTestSenseResponder()

            onePass(sprite: newArkon.sprite, metabolism: newArkon.metabolism)
        }
    }

    struct CannibalsTestContactResponder: ContactResponseProtocol {
        let ownerArkon: Arkon

        func respond(_ contactedBodies: [SKPhysicsBody]) {
            for body in contactedBodies where body.node is Thorax {
                let sprite = (body.node as? SKSpriteNode)!
                if sprite.arkon.selectoid.fishNumber < ownerArkon.selectoid.fishNumber {
                    ownerArkon.metabolism.parasitize(sprite.arkon.metabolism)
                    break
                }
            }
        }
    }

    struct CannibalsTestSenseResponder: SenseResponseProtocol {
        func respond(_ sensedBodies: [SKPhysicsBody]) {
            sensedBodies.forEach { ($0.node as? SKSpriteNode)?.color = .yellow }
        }
    }

    static func cannibalsTest(portal: SKSpriteNode) {
        for a in 0..<30 {
            let newArkon = Arkon(parentBiases: nil, parentWeights: nil)
            arkonHangar[a] = newArkon
            newArkon.sprite.position = portal.getRandomPoint()
            newArkon.sprite.zRotation = CGFloat.random(in: -CGFloat.pi..<CGFloat.pi)

            newArkon.contactDetector!.contactResponder =
                PreyTestContactResponder(ownerArkon: newArkon)

            newArkon.contactDetector!.senseResponder = PreyTestSenseResponder()

            onePass(sprite: newArkon.sprite, metabolism: newArkon.metabolism)
        }
    }

    struct GrazeTestContactResponder: ContactResponseProtocol {
        let ownerArkon: Arkon

        func respond(_ contactedBodies: [SKPhysicsBody]) {
            for body in contactedBodies {
                let sprite = (body.node as? SKSpriteNode)!
                let background = (sprite.parent as? SKSpriteNode)!

                let harvested = sprite.manna.harvest()
                ownerArkon.metabolism.absorbEnergy(harvested)

                let actions = Manna.triggerDeathCycle(sprite: sprite, background: background)
                sprite.run(actions)
            }
        }

    }

    static func grazeTest() {
        for a in 0..<1 {
            let newArkon = Arkon(parentBiases: nil, parentWeights: nil)
            arkonHangar[a] = newArkon
            newArkon.sprite.position = CGPoint.zero

            newArkon.contactDetector!.contactResponder =
                GrazeTestContactResponder(ownerArkon: newArkon)

            newArkon.contactDetector!.senseResponder = ContactTestSenseResponder()

            onePass(sprite: newArkon.sprite, metabolism: newArkon.metabolism)
        }
    }

    static func omnivoresTest(portal: SKSpriteNode) {
        for _ in 0..<100 { spawn(portal: portal) }
    }

    struct PreyTestContactResponder: ContactResponseProtocol {
        let ownerArkon: Arkon

        func respond(_ contactedBodies: [SKPhysicsBody]) {
            for body in contactedBodies where body.node is Thorax {
                let sprite = (body.node as? SKSpriteNode)!

                ownerArkon.metabolism.parasitize(sprite.arkon.metabolism)
            }
        }
    }

    struct PreyTestSenseResponder: SenseResponseProtocol {
        func respond(_ sensedBodies: [SKPhysicsBody]) {
            sensedBodies.forEach { ($0.node as? SKSpriteNode)?.color = .yellow }
        }
    }

    static func preyTest(portal: SKSpriteNode) {
        for a in 0..<100 {
            let newArkon = Arkon(parentBiases: nil, parentWeights: nil)
            arkonHangar[a] = newArkon
            newArkon.sprite.position = portal.getRandomPoint()

            if a > 0 { continue }

            newArkon.sprite.position = CGPoint.zero

            newArkon.contactDetector!.contactResponder =
                PreyTestContactResponder(ownerArkon: newArkon)

            newArkon.contactDetector!.senseResponder = PreyTestSenseResponder()

            onePass(sprite: newArkon.sprite, metabolism: newArkon.metabolism)
        }
    }
}
