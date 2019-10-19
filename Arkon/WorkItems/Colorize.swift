import GameplayKit

extension Arkon {
    func colorize(
        metabolism: Metabolism, age: TimeInterval,
        completion: @escaping CoordinatorCallback
    ) {
        let workItem = { [weak self] in
            guard let myself = self else {
//                print("Bailing in colorize")
                return
            }
            myself.colorize_(metabolism, age)
        }

        Lockable<Void>().lock(workItem, completion)
    }

    private func colorize_(
        _ metabolism: Metabolism, _ age: TimeInterval
    ) {
        let ef = metabolism.fungibleEnergyFullness
        nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

        let baseColor: Int
        if selectoid.fishNumber < 10 {
            baseColor = 0xFF_00_00
        } else {
            baseColor = (metabolism.spawnEnergyFullness > 0) ?
                Arkon.brightColor : Arkon.standardColor
        }

        let four: CGFloat = 4
        self.sprite.color = ColorGradient.makeColorMixRedBlue(
            baseColor: baseColor,
            redPercentage: metabolism.spawnEnergyFullness,
            bluePercentage: max((four - CGFloat(age)) / four, 0.0)
        )

        self.sprite.colorBlendFactor = metabolism.oxygenLevel
    }
}
