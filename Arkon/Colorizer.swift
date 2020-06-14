import GameplayKit

class Colorizer {
    var babyBumpIsShowing = false
    weak var stepper: Stepper?

    init(_ stepper: Stepper) { self.stepper = stepper }

    func colorize(_ onComplete: @escaping () -> Void) {
        SceneDispatch.shared.schedule { [unowned self] in
            let s = "\(#line):\(#file)"
            Debug.log(level: 197) { s }
            self.colorize_()
            onComplete()
        }
    }
}

extension Colorizer {
    private func colorize_() {
        Debug.log(level:168) { "Colorize \(six(stepper!.name))" }

        if Arkonia.debugColorIsEnabled {
            Debug.debugColor(stepper!, .brown, .brown)
        } else {
            setNoseColor()
        }

        setThoraxScale()

        let babyBumpShouldBeShowing =
            (stepper!.metabolism.spawn?.oxygenStore.level ?? 0) > 0

        switch (babyBumpShouldBeShowing, stepper!.babyBumpIsShowing) {
        case (true, false):
            lookPregnant()
            stepper!.babyBumpIsShowing = true

        case (false, true):
            lookNotPregnant()
            stepper!.babyBumpIsShowing = false

        default: break
        }
    }

    private func setNoseColor() {
        stepper!.nose.colorBlendFactor = 1 - stepper!.metabolism.asphyxiation
    }

    private func setThoraxScale() {
        let m = stepper!.metabolism!
        let effectiveMass = m.mass - (m.embryo?.mass ?? 0)
        let scale = log(effectiveMass + 1)
        stepper!.thorax.setScale(Arkonia.arkonScaleFactor * scale / Arkonia.zoomFactor)
    }

    private func lookNotPregnant() {
        stepper!.nose.setScale(Arkonia.noseScaleFactor)
    }

    private func lookPregnant() {
        let m = stepper!.metabolism!
        let f: CGFloat = m.spawn?.fatStore?.fullness ?? 0.25
        let s: CGFloat = Arkonia.arkonScaleFactor * Arkonia.noseScaleFactor *
            Arkonia.zoomFactor * f

        stepper!.nose.yScale = s
        stepper!.nose.xScale = s
    }
}
