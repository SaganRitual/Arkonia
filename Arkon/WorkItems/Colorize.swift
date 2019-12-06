import GameplayKit

final class Colorize: Dispatchable {
    internal override func launch_() { aColorize() }
}

func six(_ string: String?) -> String { return String(string?.prefix(6) ?? "<no owner?>") }

extension Colorize {
    func aColorize() {
        Log.L.write("Colorize.launch_ \(six(scratch?.stepper?.name))", level: 15)
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let ws = ch.worldStats else { fatalError() }

        let age = st.getAge(ws.currentTime)
        st.colorizeProper(age)

        dp.disengage()
    }
}

extension Stepper {

    func colorizeProper(_ myAge: Int) {
//        nose.alpha = CGFloat(1 - (metabolism.oxygenLevel / 1))
//
////        let ef = metabolism.fungibleEnergyFullness
////        nose.color = ColorGradient.makeColor(Int(ef * 100), 100)
//
//        let scale = constrain(0.50 + metabolism.spawnEnergyFullness, lo: 0.50, hi: 0.75)
//        sprite.setScale(scale)
//
//        let baseColor: Int
//        if fishNumber > 0 {
//            baseColor = 0xFF_00_00
//        } else {
//            baseColor = (metabolism.spawnEnergyFullness > 0) ?
//                Larva.Constants.brightColor : Larva.Constants.standardColor
//        }
//
//        let four: CGFloat = 4
//        self.sprite.color = ColorGradient.makeColorMixRedBlue(
//            baseColor: baseColor,
//            redPercentage: metabolism.spawnEnergyFullness,
//            bluePercentage: max((four - CGFloat(myAge)) / four, 0.0)
//        )
//
        self.sprite.colorBlendFactor = metabolism.fungibleEnergyFullness
    }
}
