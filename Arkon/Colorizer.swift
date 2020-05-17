import GameplayKit

class Colorizer {
    var babyBumpIsShowing = false
    let scratch: Scratchpad

    init(_ scratch: Scratchpad) { self.scratch = scratch }

    func colorize(_ onComplete: @escaping () -> Void) {
        SceneDispatch.shared.schedule { [unowned self] in
            self.colorize_()
            onComplete()
        }
    }
}

extension Colorizer {
    private func colorize_() {
        Debug.log(level:168) { "Colorize \(six(scratch.stepper.name))" }

        Debug.debugColor(scratch.stepper, .blue, .blue)

        let babyBumpShouldBeShowing =
            (scratch.stepper.metabolism.spawn?.oxygenStore.level ?? 0) > 0

        switch (babyBumpShouldBeShowing, scratch.babyBumpIsShowing) {
        case (true, false):
            lookPregnant(scratch.stepper.nose)
            scratch.babyBumpIsShowing = true

        case (false, true):
            lookNotPregnant(scratch.stepper.nose)
            scratch.babyBumpIsShowing = false

        default: break
        }
    }

    private func lookNotPregnant(_ nose: SKSpriteNode) {
        nose.setScale(Arkonia.noseScaleFactor)
    }

    private func lookPregnant(_ nose: SKSpriteNode) {
        nose.yScale = Arkonia.noseScaleFactor / Arkonia.zoomFactor * 2
        nose.xScale = Arkonia.noseScaleFactor * Arkonia.zoomFactor
    }
}
