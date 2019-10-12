import GameplayKit

extension Arkon {
    func colorize(
        metabolism: Metabolism, age: TimeInterval,
        completion: @escaping CoordinatorCallback
    ) {
        let workItem = { [unowned self] in
            self.colorize_(metabolism, age, completion)
            completion()
        }

        workItem()
//        syncQueue.async(flags: .barrier, execute: workItem)
    }

    private func colorize_(
        _ metabolism: Metabolism, _ age: TimeInterval,
        _ completion: @escaping CoordinatorCallback
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
