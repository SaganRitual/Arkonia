import GameplayKit

final class Colorize: Dispatchable {
    var babyBumpIsShowing = false

    internal override func launch() {
        Debug.log(level: 102) { "colorize" }
        SceneDispatch.shared.schedule {  [unowned self] in self.colorize() } // Catch dumb mistakes
    }
}

extension Colorize {
    func colorize() {
        Debug.log(level:168) { "Colorize \(six(scratch.stepper.name))" }

        Debug.debugColor(scratch.stepper, .blue, .blue)

        let babyBumpShouldBeShowing =
            scratch.stepper.metabolism.spawn.level >
            (scratch.stepper.metabolism.spawnCost * 0.8)

        switch (babyBumpShouldBeShowing, babyBumpIsShowing) {
        case (true, false):
            WorkItems.lookPregnant(scratch.stepper.metabolism.lungs.level, scratch.stepper.nose)
            babyBumpIsShowing = true

        case (false, true):
            WorkItems.lookNotPregnant(scratch.stepper.nose)
            babyBumpIsShowing = false

        default: break
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
