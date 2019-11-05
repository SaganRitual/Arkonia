import SpriteKit

class Manna {

    static let colorBlendMinimum: CGFloat = 0.25
    static let colorBlendRangeWidth: CGFloat = 1 - colorBlendMinimum
    static let fullGrowthDurationSeconds: TimeInterval = 5
    static let growthRateGranularitySeconds: TimeInterval = 0.1
    static let growthRateJoulesPerSecond: CGFloat = 5000

    var rebloomDelay = 1.0
    var isCaptured = false
    weak var sprite: SKSpriteNode!

    var energyContentInJoules: CGFloat {
        let fudgeFactor: CGFloat = 1
        var f = fudgeFactor * (sprite.colorBlendFactor - Manna.colorBlendMinimum)
        f /= Manna.colorBlendRangeWidth
        f *= Manna.growthRateJoulesPerSecond * CGFloat(Manna.fullGrowthDurationSeconds)
        return f * 1.0//CGFloat(World.shared.foodValue)
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
