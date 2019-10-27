import GameplayKit

final class Colorize: Dispatchable {
    weak var dispatch: Dispatch!
    var runningAsBarrier: Bool { return dispatch.runningAsBarrier }
    var stats: World.StatsCopy!
    var stepper: Stepper { return dispatch.stepper }

    init(_ dispatch: Dispatch) {
        self.dispatch = dispatch
    }

    func go() {
        dispatch.go({ self.aColorize() }, runAsBarrier: true)
    }

}

extension Colorize {
    func aColorize() {
        assert(runningAsBarrier == true)

        stats = World.stats.copy()

        let age = stats.currentTime - stepper.birthday
        dispatch.stepper.colorizeProper(dispatch, age)
        dispatch.shiftSetupGrid()
    }
}

extension Stepper {

    func colorizeProper(_ dispatch: Dispatch, _ myAge: Int) {
        let ef = metabolism.fungibleEnergyFullness
        nose.color = ColorGradient.makeColor(Int(ef * 100), 100)

        let baseColor: Int
        if fishNumber > 0 {
            baseColor = 0xFF_00_00
        } else {
            baseColor = (metabolism.spawnEnergyFullness > 0) ?
                ArkonFactory.brightColor : ArkonFactory.standardColor
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
