import SpriteKit

extension Maneuvers {
    struct DummyEnergyPacket: EnergyPacketProtocol {
        let energyContent: CGFloat
    }

    struct EnergySource: EnergySourceProtocol {
        func withdrawFromReady(_ cJoules: CGFloat) -> CGFloat { return cJoules }
        func withdrawFromSpawn(_ cJoules: CGFloat) -> CGFloat { return cJoules }
    }

    static var tenPass = 0

    static func getActions(sprite: SKSpriteNode) -> SKAction {
        let maneuvers = Maneuvers(energySource: EnergySource())
        let actions = SKAction.sequence([
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 1, 0, 0]),  // thrust
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 0, 0, 1]),  // wait
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 1, 0, 0, 0]),  // stop
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 0, 0, 1]),  // wait
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 0, 1, 0]),  // rotate
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 0, 0, 1]),  // wait
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 1, 0, 0, 0]),  // stop
            maneuvers.selectActionPrimitive(arkon: sprite, motorOutputs: [1, 0, 0, 0, 1])   // wait
            ])

        return actions
    }

    static func onePass(sprite: SKSpriteNode) {
        if tenPass >= 10 { return }
        tenPass += 1

        let actions = getActions(sprite: sprite)
        let preWait = SKAction.wait(forDuration: 5.0)
        let sequence = SKAction.sequence([preWait, actions])
        sprite.run(sequence) { onePass(sprite: sprite) }
    }

    static func selfTest(background: SKSpriteNode, scene: SKScene) {
        let sprite = SpriteFactory(scene: scene).arkonsHangar.makeSprite()
        sprite.setScale(0.5)

        background.addChild(sprite)

        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        sprite.physicsBody!.mass = 1
        onePass(sprite: sprite)

        //        print("oass", sprite.physicsBody!.mass)//, nose.physicsBody!.mass)
    }
}
