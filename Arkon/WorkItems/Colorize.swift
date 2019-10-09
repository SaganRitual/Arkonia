import GameplayKit

extension Arkon {
    func colorize(bandaid: Coordinator, age: TimeInterval) {
        let action = SKAction.run { [unowned self] in
            let ef = bandaid.metabolism.fungibleEnergyFullness
            bandaid.core.nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

            let baseColor: Int
            if bandaid.core.selectoid.fishNumber < 10 {
                baseColor = 0xFF_00_00
            } else {
                baseColor = (bandaid.metabolism.spawnEnergyFullness > 0) ?
                    Arkon.brightColor : Arkon.standardColor
            }

            let four: CGFloat = 4
            self.sprite.color = ColorGradient.makeColorMixRedBlue(
                baseColor: baseColor,
                redPercentage: bandaid.metabolism.spawnEnergyFullness,
                bluePercentage: max((four - CGFloat(age)) / four, 0.0)
            )

            self.sprite.colorBlendFactor = bandaid.metabolism.oxygenLevel
        }

        sprite.run(action) {
            bandaid.dispatch(.actionComplete_metabolorize)
        }
    }
}
