import GameplayKit

final class Colorize: Dispatchable {
    weak var scratch: Scratchpad?

    init(_ scratch: Scratchpad) { self.scratch = scratch }

    func launch() { aColorize() }
}

func six(_ string: String?) -> String { return String(string?.prefix(6) ?? "ottffs") }

extension Colorize {
    func aColorize() {
        guard let sc = scratch else { fatalError() }
        guard let st = sc.stepper else { fatalError() }
        guard let ws = sc.worldStats else { fatalError() }

        let age = ws.currentTime - st.birthday
        st.colorizeProper(age)
    }
}

extension Stepper {

    func colorizeProper(_ myAge: Int) {
        let ef = metabolism.fungibleEnergyFullness
        nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

        let baseColor: Int
        if fishNumber > 0 {
            baseColor = 0xFF_00_00
        } else {
            baseColor = (metabolism.spawnEnergyFullness > 0) ?
                Wangkhi.brightColor : Wangkhi.standardColor
        }

        let four: CGFloat = 4
        self.sprite.color = ColorGradient.makeColorMixRedBlue(
            baseColor: baseColor,
            redPercentage: metabolism.spawnEnergyFullness,
            bluePercentage: max((four - CGFloat(myAge)) / four, 0.0)
        )

        self.sprite.colorBlendFactor = metabolism.oxygenLevel
    }
}
