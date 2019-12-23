import GameplayKit

final class Colorize: Dispatchable {
    internal override func launch() { aColorize() }
}

func six(_ string: String?) -> String { return String(string?.prefix(15) ?? "<no input>") }

extension Colorize {
    func aColorize() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.debugColor(st, .blue, .blue)

        precondition(ch.engagerKey?.sprite?.getStepper(require: false)?.name == st.name &&
                ch.engagerKey?.gridPosition == st.gridCell.gridPosition &&
                ch.engagerKey?.sprite?.getStepper(require: false)?.gridCell.gridPosition == st.gridCell.gridPosition
        )

        st.colorizeProper { Grid.shared.serialQueue.async { dp.disengage() } }
    }
}

extension Stepper {

    func colorizeProper(_ onComplete: @escaping () -> Void) {
        nose.colorBlendFactor = CGFloat(1 - metabolism.oxygenLevel)

        let babyBumpIsRunning = sprite.action(forKey: "baby-bump") != nil
        let babyBumpShouldBeShowing = metabolism.spawnReserves.level > (getSpawnCost() * 0.5)
        let xScale = Arkonia.spriteScale
        let yScale = Arkonia.spriteScale

        if babyBumpShouldBeShowing && !babyBumpIsRunning {
            Log.L.write("action on", level: 47)
            let swell = SKAction.scale(by: 1.5, duration: 0.4)
            let shrink = SKAction.scaleX(to: xScale, y: yScale, duration: 0.1)
            let discolor = SKAction.colorize(with: .purple, colorBlendFactor: 1, duration: 0.25)
            let recolor = SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 0.25)
            let throb = SKAction.sequence([swell, shrink])
            let throbColor = SKAction.sequence([discolor, recolor])
            let throbEverything = SKAction.group([throb, throbColor])
            let forever = SKAction.repeatForever(throbEverything)

            let noseGrow = SKAction.scale(by: 2.0, duration: 0.4)
            let noseShrink = SKAction.scale(to: 0.5, duration: 0.1)
            let noseSequence = SKAction.sequence([noseGrow, noseShrink])
            let noseDiscolor = SKAction.colorize(with: .purple, colorBlendFactor: 1, duration: 0.25)
            let noseRecolor = SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 0.25)
            let noseColorSequence = SKAction.group([noseDiscolor, noseRecolor])
            let noseGroup = SKAction.group([noseSequence, noseColorSequence])
            let noseForever = SKAction.repeatForever(noseGroup)

            let wrapper = SKAction.run {
                self.sprite.run(forever, withKey: "baby-bump")
                self.nose.run(noseForever, withKey: "baby-bump-nose")
            }

            sprite.run(wrapper) { onComplete() }
            return
        }

        if babyBumpIsRunning && !babyBumpShouldBeShowing {
            Log.L.write("action off", level: 47)
            sprite.removeAction(forKey: "baby-bump")

            let shrink = SKAction.scaleX(to: xScale, y: yScale, duration: 0.5)
            let recolor = SKAction.colorize(with: .green, colorBlendFactor: 1, duration: 0.75)
            let unthrob = SKAction.group([shrink, recolor])

            sprite.run(unthrob) { onComplete() }
            return
        }

        self.sprite.colorBlendFactor = metabolism.fungibleEnergyFullness
        onComplete()
    }
}
