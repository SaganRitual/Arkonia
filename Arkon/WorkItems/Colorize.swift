import GameplayKit

final class Colorize: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Colorize()", level: 3)
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    private func launch_() { aColorize() }
}

func six(_ string: String?) -> String { return String(string?.prefix(6) ?? "<no owner?>") }

extension Colorize {
    func aColorize() {
        Log.L.write("Colorize.launch_ \(six(scratch?.stepper?.name))", level: 3)
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let ws = ch.worldStats else { fatalError() }

        let age = ws.currentTime - st.birthday
        st.colorizeProper(age)

        dp.disengage()
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
