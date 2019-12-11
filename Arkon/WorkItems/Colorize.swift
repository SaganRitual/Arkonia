import GameplayKit

final class Colorize: Dispatchable {
    internal override func launch_() { aColorize() }
}

func six(_ string: String?) -> String { return String(string?.prefix(15) ?? "<no input>") }

extension Colorize {
    func aColorize() {
        Log.L.write("Colorize.launch_ \(six(scratch?.stepper?.name))", level: 15)
        guard let (_, dp, st) = scratch?.getKeypoints() else { fatalError() }

        st.colorizeProper()
        dp.disengage()
    }
}

extension Stepper {

    func colorizeProper() {
        nose.colorBlendFactor = CGFloat(1 - (metabolism.oxygenLevel / 1))

        let babyBumpIsRunning = sprite.action(forKey: "baby-bump") != nil
        let babyBumpShouldBeShowing = metabolism.spawnReserves.level > (getSpawnCost() * 0.5)
        let xScale = ArkoniaCentral.spriteScale
        let yScale = ArkoniaCentral.spriteScale

        if babyBumpShouldBeShowing && !babyBumpIsRunning {
            Log.L.write("action on", level: 47)
            let swell = SKAction.scale(by: 1.5, duration: 0.5)
            let shrink = SKAction.scaleX(to: xScale, y: yScale, duration: 0.5)
            let discolor = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 0.75)
            let recolor = SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 0.75)
            let throb = SKAction.sequence([swell, shrink])
            let throbColor = SKAction.sequence([discolor, recolor])
            let throbEverything = SKAction.group([throb, throbColor])
            let forever = SKAction.repeatForever(throbEverything)
            sprite.run(forever, withKey: "baby-bump")
            return
        }

        if babyBumpIsRunning && !babyBumpShouldBeShowing {
            Log.L.write("action off", level: 47)
            sprite.removeAction(forKey: "baby-bump")

            let shrink = SKAction.scaleX(to: xScale, y: yScale, duration: 0.5)
            let recolor = SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 0.75)
            let unthrob = SKAction.group([shrink, recolor])

            sprite.run(unthrob)
            return
        }
//
//        nose.color = (debugFlasher == true) ? .gray : .yellow
//        debugFlasher = (debugFlasher == true) ? false : true

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
