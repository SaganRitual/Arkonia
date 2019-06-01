import SpriteKit

class Manna {

    static let morselCount = 100
    static let colorBlendMinimum: CGFloat = 0.25
    static let colorBlendRangeWidth: CGFloat = 0.75
    static let fullGrowthDurationSeconds: TimeInterval = 2.0
    static let growthRateGranularitySeconds: TimeInterval = 0.1
    static let growthRateJoulesPerSecond: CGFloat = 1000.0

    let sprite: SKSpriteNode

    init(_ sprite: SKSpriteNode) { self.sprite = sprite }
}

extension Manna {
    static func runLifeCycle(sprite: SKSpriteNode, background: SKSpriteNode) {
        let colorAction = SKAction.colorize(
            withColorBlendFactor: 1.0, duration: Manna.fullGrowthDurationSeconds
        )

        let beEatenAction = SKAction.run {
            sprite.removeFromParent()
            sprite.colorBlendFactor = Manna.colorBlendMinimum
        }

        let waitAction = SKAction.wait(forDuration: 1.0)

        let replantAction = SKAction.run {
            let w = background.size.width / 2
            let h = background.size.height / 2

            let xRange = -w..<w
            let yRange = -h..<h

            sprite.position = CGPoint.random(xRange: xRange, yRange: yRange)
            background.addChild(sprite)
        }

        let growthAction = SKAction.sequence([colorAction, beEatenAction])
        let rebirthAction = SKAction.sequence([waitAction, replantAction])
        sprite.run(growthAction) {
            background.run(rebirthAction) {
                runLifeCycle(sprite: sprite, background: background)
            }
        }
    }

    static func selfTest(background: SKSpriteNode, scene: SKScene) {
        let sprite = SpriteFactory(scene: scene).mannaHangar.makeSprite()
        background.addChild(sprite)

        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
        sprite.physicsBody!.mass = 1
        sprite.setScale(0.1)
        sprite.color = .orange
        sprite.colorBlendFactor = Manna.colorBlendMinimum

        runLifeCycle(sprite: sprite, background: background)
    }
}
