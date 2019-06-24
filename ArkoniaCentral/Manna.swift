import SpriteKit

extension SKSpriteNode {
    var manna: Manna {
        get { return (userData!["manna"] as? Manna)! }
        set { userData!["manna"] = newValue }
    }
}

class Manna {

    static let cMorsels = 1000
    static let colorBlendMinimum: CGFloat = 0.25
    static let colorBlendRangeWidth: CGFloat = 1 - colorBlendMinimum
    static let fullGrowthDurationSeconds: TimeInterval = 2.0
    static let growthRateGranularitySeconds: TimeInterval = 0.1
    static let growthRateJoulesPerSecond: CGFloat = 1000.0

    var isCaptured = false
    let sprite: SKSpriteNode

    var energyContentInJoules: CGFloat {
        var f = 25 * (sprite.colorBlendFactor - Manna.colorBlendMinimum)
        f /= Manna.colorBlendRangeWidth
        f *= Manna.growthRateJoulesPerSecond * CGFloat(Manna.fullGrowthDurationSeconds)
        return f
    }

    init(_ sprite: SKSpriteNode) { self.sprite = sprite }

    func harvest() -> CGFloat {
        defer { sprite.colorBlendFactor = Manna.colorBlendMinimum }
        return energyContentInJoules
    }
}

extension Manna {
    static func triggerDeathCycle(sprite: SKSpriteNode, background: SKSpriteNode) -> SKAction {
        if sprite.manna.isCaptured { return SKAction.run {} }

        sprite.manna.isCaptured = true

        let unPhysics = SKAction.run { sprite.physicsBody!.isDynamic = false }
        let fadeOut = SKAction.fadeOut(withDuration: 0.001)
        let wait = getWaitAction()

        let replant = SKAction.run {
            sprite.position = background.getRandomPoint()
            sprite.physicsBody!.isDynamic = true
            sprite.manna.isCaptured = false
        }

        let fadeIn = SKAction.fadeIn(withDuration: 0.001)
        let rebloom = getColorAction()

//        print("tdc\(boof)"); boof += 1
        return SKAction.sequence([unPhysics, fadeOut, wait, replant, fadeIn, rebloom])
    }

    static var boof = 0

    static func getBeEatenAction(sprite: SKSpriteNode) -> SKAction {
        return SKAction.run {
            sprite.removeFromParent()
            sprite.colorBlendFactor = Manna.colorBlendMinimum
        }
    }

    static func getColorAction() -> SKAction {
        return SKAction.colorize(
            with: .orange, colorBlendFactor: 1.0, duration: Manna.fullGrowthDurationSeconds
        )
    }

    static func getWaitAction() -> SKAction { return SKAction.wait(forDuration: 1.0) }

    static func getReplantAction(sprite: SKSpriteNode, background: SKSpriteNode) -> SKAction {
        return SKAction.run {
            sprite.position = background.getRandomPoint()
            background.addChild(sprite)
        }
    }

}

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

    static func plantAllManna(background: SKSpriteNode, spriteFactory: SpriteFactory) {
        for _ in 0..<Manna.cMorsels {
            let sprite = spriteFactory.mannaHangar.makeSprite()
            let manna = Manna(sprite)

            sprite.userData = ["manna": manna]
            sprite.position = background.getRandomPoint()

            background.addChild(sprite)

            sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 2)
            sprite.physicsBody!.mass = 1
            sprite.setScale(0.1)
            sprite.color = .orange
            sprite.colorBlendFactor = Manna.colorBlendMinimum

            sprite.physicsBody!.categoryBitMask = PhysicsBitmask.mannaBody.rawValue
            sprite.physicsBody!.collisionBitMask = 0
            sprite.physicsBody!.contactTestBitMask = 0

            runGrowthPhase(sprite: sprite, background: background)
        }
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

    static func runGrowthPhase(sprite: SKSpriteNode, background: SKSpriteNode) {
        let colorAction = SKAction.colorize(
            withColorBlendFactor: 1.0, duration: Manna.fullGrowthDurationSeconds
        )

        sprite.run(colorAction)
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
