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

        if Arkonia.debugColorIsEnabled {
            Debug.debugColor(scratch.stepper, .brown, .brown)
        } else {
            setNoseColor(scratch.stepper.metabolism, scratch.stepper.nose)
        }

        setThoraxScale(scratch.stepper.metabolism, scratch.stepper.sprite)

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

    private func setNoseColor(_ metabolism: Metabolism, _ nose: SKSpriteNode) {
        if metabolism.embryo != nil { nose.color = .blue }
        else if metabolism.spawn != nil { nose.color = .red }
        else { nose.color = .white }

        nose.colorBlendFactor = 1
        nose.alpha = 1 - metabolism.asphyxiation
    }

    private func setThoraxScale(_ metabolism: Metabolism, _ thorax: SKSpriteNode) {
        let effectiveMass = metabolism.mass - (metabolism.embryo?.mass ?? 0)
        let scale = log(effectiveMass + 1)
        thorax.setScale(Arkonia.arkonScaleFactor * scale / Arkonia.zoomFactor)
    }

    private func lookNotPregnant(_ nose: SKSpriteNode) {
        nose.setScale(Arkonia.noseScaleFactor)
    }

    private func lookPregnant(_ nose: SKSpriteNode) {
        nose.yScale = Arkonia.noseScaleFactor / Arkonia.zoomFactor * 2
        nose.xScale = Arkonia.noseScaleFactor * Arkonia.zoomFactor
    }
}
