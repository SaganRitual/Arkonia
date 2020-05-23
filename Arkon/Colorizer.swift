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
            setNoseColor()
        }

        setThoraxScale()

        let babyBumpShouldBeShowing =
            (scratch.stepper.metabolism.spawn?.oxygenStore.level ?? 0) > 0

        switch (babyBumpShouldBeShowing, scratch.babyBumpIsShowing) {
        case (true, false):
            lookPregnant()
            scratch.babyBumpIsShowing = true

        case (false, true):
            lookNotPregnant()
            scratch.babyBumpIsShowing = false

        default: break
        }
    }

    private func setNoseColor() {
        scratch.stepper.nose.colorBlendFactor = 1 - scratch.stepper.metabolism.asphyxiation
    }

    private func setThoraxScale() {
        let m = scratch.stepper.metabolism!
        let effectiveMass = m.mass - (m.embryo?.mass ?? 0)
        let scale = log(effectiveMass + 1)
        scratch.stepper.sprite.setScale(Arkonia.arkonScaleFactor * scale / Arkonia.zoomFactor)
    }

    private func lookNotPregnant() {
        scratch.stepper.nose.setScale(Arkonia.noseScaleFactor)
    }

    private func lookPregnant() {
        let m = scratch.stepper.metabolism!
        let f: CGFloat = m.spawn?.fatStore?.fullness ?? 0.25
        let s: CGFloat = Arkonia.arkonScaleFactor * Arkonia.noseScaleFactor *
            Arkonia.zoomFactor * f

        scratch.stepper.nose.yScale = s
        scratch.stepper.nose.xScale = s
    }
}
