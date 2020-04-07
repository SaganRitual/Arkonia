import GameplayKit

final class Colorize: Dispatchable {
    internal override func launch() {
        Debug.log(level: 102) { "colorize" }
        SceneDispatch.schedule {  [unowned self] in self.colorize() } // Catch dumb mistakes
    }
}

extension Colorize {
    func colorize() {
        Debug.log(level:71) { "Colorize \(six(scratch.stepper.name))" }

        Debug.debugColor(scratch.stepper, .blue, .blue)

        let babyBumpShouldBeShowing = scratch.stepper.metabolism.spawnReserves.level > (scratch.stepper.getSpawnCost() * 0.5)

        switch babyBumpShouldBeShowing {
        case true:  WorkItems.lookPregnant(scratch.stepper.metabolism.oxygenLevel, scratch.stepper.nose)
        case false: WorkItems.lookNotPregnant(scratch.stepper.nose)
        }

        scratch.dispatch!.disengage()
    }
}

extension WorkItems {
    private static let f: CGFloat = Arkonia.zoomFactor

    static func lookPregnant(_ oxygenLevel: CGFloat, _ nose: SKSpriteNode) {
        nose.yScale = Arkonia.noseScaleFactor / f * 2
        nose.xScale = Arkonia.noseScaleFactor * f
    }
}

extension WorkItems {
    static func lookNotPregnant(_ nose: SKSpriteNode) {
        nose.setScale(Arkonia.noseScaleFactor)
    }
}
