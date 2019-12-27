import SpriteKit

class Manna {
    typealias OnComplete1p = (CGFloat) -> Void

    static let colorBlendMaximum: CGFloat = 0.45
    static let colorBlendMinimum: CGFloat = 0.25
    static var colorBlendRangeWidth: CGFloat { return colorBlendMaximum - colorBlendMinimum }
    static let fullGrowthDurationSeconds: TimeInterval = 1
    static var maxEnergyContentInJoules: CGFloat = 500

    static var growthRateJoulesPerSecond: CGFloat {
        return maxEnergyContentInJoules / CGFloat(fullGrowthDurationSeconds)
    }

    static var populator = Garden()

    var rebloomDelay = 1.0
    weak var sprite: SKSpriteNode!

    init(_ sprite: SKSpriteNode) { self.sprite = sprite }

    static func attachManna(_ manna: Manna, to sprite: SKSpriteNode) {
        sprite.userData![SpriteUserDataKey.manna] = manna
        sprite.name = "manna-" + (sprite.name ?? "huh?")
    }

    func getEnergyContentInJoules(_ onComplete: @escaping Clock.OnComplete1CGFloatp) {
        Clock.shared.getEntropy { entropy in
            let energyContent = self.getEnergyContentInJoules(entropy)

            Log.L.write("energyContent: \(energyContent) joules; including entropy \(entropy)", level: 66)
            onComplete(energyContent)
        }
    }

    func getEnergyContentInJoules(_ entropy: CGFloat) -> CGFloat {
        let fudgeFactor: CGFloat = 1
        let f0 = max(sprite.colorBlendFactor, Manna.colorBlendMinimum)
        let f1 = fudgeFactor * abs(f0 - Manna.colorBlendMinimum)
        let f2 = f1 / Manna.colorBlendRangeWidth
        let f3: CGFloat = f2 * Manna.growthRateJoulesPerSecond * CGFloat(Manna.fullGrowthDurationSeconds)
        let f4 = f3 * (1 - entropy)

        Log.L.write(
            "colorBlendFactor \(String(format: "%-2.4f", sprite.colorBlendFactor))\n" +
            "Manna.colorBlendMinimum \(String(format: "%-2.4f", Manna.colorBlendMinimum))\n" +
            "Manna.growthRateJoulesPerSecond \(String(format: "%-2.4f", Manna.growthRateJoulesPerSecond))\n" +
            "Manna.fullGrowthDurationSeconds \(String(format: "%-2.4f", Manna.fullGrowthDurationSeconds))\n" +
            "f1, f2, f3, f4 = \(String(format: "%-2.4f", f1)), \(String(format: "%-2.4f", f2)), \(String(format: "%-2.4f", f3)), \(String(format: "%-2.4f", f4))\n",
            level: 66
        )

        return f4
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

    func getEnergyFullness(_ onComplete: @escaping Clock.OnComplete1CGFloatp) {
        getEnergyContentInJoules { onComplete($0 / Manna.maxEnergyContentInJoules) }
    }

    func harvest(_ onComplete: @escaping Clock.OnComplete1CGFloatp) {
        getEnergyContentInJoules { net in
            self.sprite.colorBlendFactor = Manna.colorBlendMinimum
            onComplete(net)
        }
    }
}
