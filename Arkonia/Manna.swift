import SpriteKit

class Manna {
    typealias OnComplete1p = (CGFloat) -> Void

    static let colorBlendMaximum: CGFloat = 0.35
    static let colorBlendMinimum: CGFloat = 0.15
    static var colorBlendRangeWidth: CGFloat { return colorBlendMaximum - colorBlendMinimum }
    static let fullGrowthDurationSeconds: TimeInterval = 1

    static var growthRateJoulesPerSecond: CGFloat {
        return Arkonia.maxMannaEnergyContentInJoules / CGFloat(fullGrowthDurationSeconds)
    }

    static var populator = Garden()

    var rebloomDelay = 1.0
    weak var sprite: SKSpriteNode!

    init(_ sprite: SKSpriteNode) { self.sprite = sprite }

    func getEnergyContentInJoules(_ entropy: CGFloat) -> CGFloat {
        let top = max(sprite.colorBlendFactor, Manna.colorBlendMinimum)
        let width = abs(top - Manna.colorBlendMinimum)
        let fullness = width / Manna.colorBlendRangeWidth
        let energyContent: CGFloat = fullness * Manna.growthRateJoulesPerSecond * CGFloat(Manna.fullGrowthDurationSeconds)
        let entropized = energyContent * (1 - entropy)

        Log.L.write(
            "colorBlendFactor \(String(format: "%-2.4f", sprite.colorBlendFactor))\n" +
            "Manna.colorBlendMinimum \(String(format: "%-2.4f", Manna.colorBlendMinimum))\n" +
            "Manna.growthRateJoulesPerSecond \(String(format: "%-2.4f", Manna.growthRateJoulesPerSecond))\n" +
            "Manna.fullGrowthDurationSeconds \(String(format: "%-2.4f", Manna.fullGrowthDurationSeconds))\n" +
            "width, fullness, energyContent, entropized = \(String(format: "%-2.4f", width)), \(String(format: "%-2.4f", fullness)), \(String(format: "%-2.4f", energyContent)), \(String(format: "%-2.4f", entropized))\n",
            level: 66
        )

        return entropized
    }

    typealias KeyLoader = ((GridCellKey) -> (Double, Double)?)

    func getNutritionInfo(_ keys: [GridCellKey], _ loadGridInput: KeyLoader) -> [Double] {
        let gridInputs: [Double] = keys.reduce([]) { partial, cell in
            guard let (contents, nutritionalValue) = loadGridInput(cell) else {
                return partial + [0, 0]
            }

            return partial + [contents, nutritionalValue]
        }

        return gridInputs
    }

    func harvest() { self.sprite.colorBlendFactor = Manna.colorBlendMinimum }
}
