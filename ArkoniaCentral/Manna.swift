import SpriteKit

class Manna {

    static let colorBlendMaximum: CGFloat = 0.45
    static let colorBlendMinimum: CGFloat = 0.25
    static var colorBlendRangeWidth: CGFloat { return colorBlendMaximum - colorBlendMinimum }
    static let fullGrowthDurationSeconds: TimeInterval = 1
    static var maxEnergyContentInJoules: CGFloat = 10000

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
        Log.L.write(
            "colorBlendFactor \(String(format: "%-2.4f", sprite.colorBlendFactor))\n" +
            "Manna.colorBlendMinimum \(String(format: "%-2.4f", Manna.colorBlendMinimum))\n" +
            "Manna.growthRateJoulesPerSecond \(String(format: "%-2.4f", Manna.growthRateJoulesPerSecond))\n" +
            "Manna.fullGrowthDurationSeconds \(String(format: "%-2.4f", Manna.fullGrowthDurationSeconds))\n" +
            "f1, f2, f3 = \(String(format: "%-2.4f", f1)), \(String(format: "%-2.4f", f2)), \(String(format: "%-2.4f", f3))\n",
            level: 30
        )

        return f3 * 1.0//CGFloat(World.shared.foodValue)
    }

    var energyFullness: CGFloat { return energyContentInJoules / Manna.maxEnergyContentInJoules }

    init(_ sprite: SKSpriteNode) { self.sprite = sprite }

    static func attachManna(_ manna: Manna, to sprite: SKSpriteNode) {
        sprite.userData![SpriteUserDataKey.manna] = manna
    }

    static func getManna(from sprite: SKSpriteNode, require: Bool = true) -> Manna? {
        guard let dictionary = sprite.userData else { fatalError() }

        guard let entry = dictionary[SpriteUserDataKey.manna] else {
            if require { fatalError() } else { return nil }
        }

        guard let manna = entry as? Manna else {
            if require { fatalError() } else { return nil }
        }

        return manna
    }

    func harvest() -> CGFloat {
        defer { sprite.colorBlendFactor = Manna.colorBlendMinimum }
        return energyContentInJoules
    }
}
