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
        label: "arkonia.mannaq", qos: .utility, target: DispatchQueue.global()
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

    func beEaten() {
        guard let background = sprite.parent as? SKSpriteNode else {
            fatalError()
        }

        Grid.getRandomPoint(sprite: sprite, background: background) { randomPoint in
            randomPoint.gridlet.contents = .manna

            let recycleAction = Manna.getRecycleAction(
                sprite: self.sprite, randomPoint: randomPoint
            )

            self.sprite.run(recycleAction)
        }
    }

    func harvest() -> CGFloat {
        defer { sprite.colorBlendFactor = Manna.colorBlendMinimum }
        return energyContentInJoules
    }
}

extension Manna {

    static func getColorAction() -> SKAction {
        return SKAction.colorize(
            with: .orange, colorBlendFactor: 1.0, duration: Manna.fullGrowthDurationSeconds
        )
    }

    func getWaitAction() -> SKAction {
//        self.rebloomDelay += 0.1
        return SKAction.wait(forDuration: self.rebloomDelay)
    }

    static func plantAllManna(background: SKSpriteNode, spriteFactory: SpriteFactory) {
        for _ in 0..<Manna.cMorsels {
            let sprite = spriteFactory.mannaHangar.makeSprite()
            let manna = Manna(sprite)

            sprite.userData = [SpriteUserDataKey.manna: manna]

            var rp: Grid.RandomGridPoint
            repeat {
                rp = background.getRandomPoint()
            } while rp.gridlet.contents != .nothing

            plantSingleManna(position: rp, sprite: sprite)

            background.addChild(sprite)

            sprite.setScale(0.1)
            sprite.color = .orange
            sprite.colorBlendFactor = Manna.colorBlendMinimum

            runGrowthPhase(sprite: sprite, background: background)
        }
    }

    static func plantSingleManna(position: Grid.RandomGridPoint, sprite: SKSpriteNode) {
        position.gridlet.contents = .manna
        position.gridlet.sprite = sprite

        sprite.position = position.cgPoint
    }

    static func runGrowthPhase(sprite: SKSpriteNode, background: SKSpriteNode) {
        let colorAction = SKAction.colorize(
            withColorBlendFactor: 1.0, duration: Manna.fullGrowthDurationSeconds
        )

        sprite.run(colorAction)
    }

    private static func getRecycleAction(
        sprite: SKSpriteNode, randomPoint: Grid.RandomGridPoint
    ) -> SKAction {
        let fadeOut = SKAction.fadeOut(withDuration: 0.001)
        let wait = sprite.manna.getWaitAction()
        let death = SKAction.sequence([fadeOut, wait])

        let replant = SKAction.run {
            plantSingleManna(position: randomPoint, sprite: sprite)
        }

        let fadeIn = SKAction.fadeIn(withDuration: 0.001)
        let rebloom = getColorAction()
        let rebirth = SKAction.sequence([fadeIn, rebloom])

        return SKAction.sequence([death, replant, rebirth])
    }

}
