import SpriteKit

class Manna {

    static let colorBlendMaximum: CGFloat = 0.75
    static let colorBlendMinimum: CGFloat = 0.25
    static var colorBlendRangeWidth: CGFloat { return colorBlendMaximum - colorBlendMinimum }
    static let fullGrowthDurationSeconds: TimeInterval = 1
    static var maxEnergyContentInJoules: CGFloat = 100

    static var growthRateJoulesPerSecond: CGFloat {
        return maxEnergyContentInJoules / CGFloat(fullGrowthDurationSeconds)
    }

    var rebloomDelay = 1.0
    var isCaptured = false
    weak var sprite: SKSpriteNode!

    var energyContentInJoules: CGFloat {
        let fudgeFactor: CGFloat = 1
        let f0 = max(sprite.colorBlendFactor, Manna.colorBlendMinimum)
        let f1 = fudgeFactor * abs(f0 - Manna.colorBlendMinimum)
        let f2 = f1 / Manna.colorBlendRangeWidth
        let f3 = f2 * Manna.growthRateJoulesPerSecond * CGFloat(Manna.fullGrowthDurationSeconds)
//        print("f", sprite.colorBlendFactor, Manna.colorBlendMinimum, Manna.growthRateJoulesPerSecond, Manna.fullGrowthDurationSeconds, f1, f2, f3)
        return f3 * 1.0//CGFloat(World.shared.foodValue)
    }

    init(_ sprite: SKSpriteNode) { self.sprite = sprite }

    static func attachManna(_ manna: Manna, to sprite: SKSpriteNode) {
        sprite.userData![SpriteUserDataKey.manna] = manna
    }

    static func getManna(from sprite: SKSpriteNode) -> Manna {
        return (sprite.userData![SpriteUserDataKey.manna] as? Manna)!
    }

    func harvest() -> CGFloat {
        defer { sprite.colorBlendFactor = Manna.colorBlendMinimum }
        return energyContentInJoules
    }

    static func releaseManna(_ manna: Manna, to sprite: SKSpriteNode) {
        sprite.userData![SpriteUserDataKey.manna] = nil
    }
}
