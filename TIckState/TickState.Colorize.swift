import GameplayKit

extension TickState {
    class Colorize: TickStateBase {
        override func work() -> TickState {
//            print("st: colorize")
            colorize()
            return .shiftable
        }

        func colorize() {
            let ef = metabolism.fungibleEnergyFullness
            core.nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

            let baseColor: Int
            if core.selectoid.fishNumber < 10 {
                baseColor = 0xFF_00_00
            } else {
                baseColor = (metabolism.spawnEnergyFullness > 0) ?
                    Arkon.brightColor : Arkon.standardColor
            }

            let four: CGFloat = 4
            sprite?.color = ColorGradient.makeColorMixRedBlue(
                baseColor: baseColor,
                redPercentage: metabolism.spawnEnergyFullness,
                bluePercentage: max((four - CGFloat(core.age)) / four, 0.0)
            )

            sprite?.colorBlendFactor = metabolism.oxygenLevel
        }
    }
}
