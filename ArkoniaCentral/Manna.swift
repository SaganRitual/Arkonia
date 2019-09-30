import SpriteKit

extension SKSpriteNode {
    var manna: Manna {
        get { return (userData![SpriteUserDataKey.manna] as? Manna)! }
        set { userData![SpriteUserDataKey.manna] = newValue }
    }
}

class Manna {

    static let cMorsels = 2500
    static let colorBlendMinimum: CGFloat = 0.25
    static let colorBlendRangeWidth: CGFloat = 1 - colorBlendMinimum
    static let fullGrowthDurationSeconds: TimeInterval = 5
    static let growthRateGranularitySeconds: TimeInterval = 0.1
    static let growthRateJoulesPerSecond: CGFloat = 5000

    static var replantQueue = DispatchQueue(
        label: "arkonia.manna.replant.queue", qos: .background
    )

    var rebloomDelay = 1.0
    var isCaptured = false
    let sprite: SKSpriteNode

    var energyContentInJoules: CGFloat {
        let fudgeFactor: CGFloat = 1
        var f = fudgeFactor * (sprite.colorBlendFactor - Manna.colorBlendMinimum)
        f /= Manna.colorBlendRangeWidth
        f *= Manna.growthRateJoulesPerSecond * CGFloat(Manna.fullGrowthDurationSeconds)
        return f * CGFloat(World.shared.foodValue)
    }

    init(_ sprite: SKSpriteNode) { self.sprite = sprite }

    func harvest() -> CGFloat {
        defer { sprite.colorBlendFactor = Manna.colorBlendMinimum }
        return energyContentInJoules
    }
}

extension Manna {
    static func plantSingleManna(position: (Gridlet, CGPoint), sprite: SKSpriteNode) {

        let gridlet = position.0
        gridlet.contents = .manna
        gridlet.sprite = sprite

        sprite.position = position.1
//        print("psm", gridlet.gridPosition, gridlet.scenePosition, sprite.position)
    }

    static func triggerDeathCycle(sprite: SKSpriteNode, background: SKSpriteNode) -> SKAction {
        if sprite.manna.isCaptured { return SKAction.run {} }

        sprite.manna.isCaptured = true

        let fadeOut = SKAction.fadeOut(withDuration: 0.001)
        let wait = sprite.manna.getWaitAction()

        let replant = SKAction.run({
            var rp: (Gridlet, CGPoint)?

            repeat {
                rp = background.getRandomPoint()
            } while rp!.0.contents != .nothing

            plantSingleManna(position: rp!, sprite: sprite)
            sprite.manna.isCaptured = false

            let fadeIn = SKAction.fadeIn(withDuration: 0.001)
            let rebloom = getColorAction()
            let sequence = SKAction.sequence([fadeIn, rebloom])
            sprite.run(sequence)

        }, queue: Manna.replantQueue)

        return SKAction.sequence([fadeOut, wait, replant])
    }

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

    func getWaitAction() -> SKAction {
        self.rebloomDelay += 0.1
        return SKAction.wait(forDuration: self.rebloomDelay)
    }

    static func getWaitAction() -> SKAction { return SKAction.wait(forDuration: 1.0) }

    static func plantAllManna(background: SKSpriteNode, spriteFactory: SpriteFactory) {
        for _ in 0..<Manna.cMorsels {
            let sprite = spriteFactory.mannaHangar.makeSprite()
            let manna = Manna(sprite)

            sprite.userData = [SpriteUserDataKey.manna: manna]

            var rp: (Gridlet, CGPoint)
            repeat {
                rp = background.getRandomPoint()
            } while rp.0.contents != .nothing

            plantSingleManna(position: rp, sprite: sprite)

            background.addChild(sprite)

            sprite.setScale(0.1)
            sprite.color = .orange
            sprite.colorBlendFactor = Manna.colorBlendMinimum

            runGrowthPhase(sprite: sprite, background: background)
        }
    }

    static func runGrowthPhase(sprite: SKSpriteNode, background: SKSpriteNode) {
        let colorAction = SKAction.colorize(
            withColorBlendFactor: 1.0, duration: Manna.fullGrowthDurationSeconds
        )

        sprite.run(colorAction)
    }

}
