import SpriteKit

extension Manna {

    static func contactTest(background: SKSpriteNode, spriteFactory: SpriteFactory) {
        plantAllManna(background: background, spriteFactory: spriteFactory)
    }

    static func grazeTest(background: SKSpriteNode, spriteFactory: SpriteFactory) {
        plantAllManna(background: background, spriteFactory: spriteFactory)
    }

    static func omnivoresTest(background: SKSpriteNode, spriteFactory: SpriteFactory) {
        plantAllManna(background: background, spriteFactory: spriteFactory)
    }

    static func runAutophageLifeCycle(sprite: SKSpriteNode, background: SKSpriteNode) {

        let growthAction = SKAction.sequence([getColorAction(), getBeEatenAction(sprite: sprite)])

        let rebirthAction = SKAction.sequence(
            [getWaitAction(), getReplantAction(sprite: sprite, background: background)]
        )

        sprite.run(growthAction) {
            background.run(rebirthAction) {
                runAutophageLifeCycle(sprite: sprite, background: background)
            }
        }
    }

    static func selfTest(background: SKSpriteNode, scene: SKScene) {
        let spriteFactory = SpriteFactory(scene: scene)

        for _ in 0..<Manna.cMorsels {
            let sprite = spriteFactory.mannaHangar.makeSprite()
            background.addChild(sprite)

            sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
            sprite.physicsBody!.mass = 1
            sprite.setScale(0.1)
            sprite.color = .orange
            sprite.colorBlendFactor = Manna.colorBlendMinimum
            sprite.position = background.getRandomPoint()

            runAutophageLifeCycle(sprite: sprite, background: background)
        }
    }
}
