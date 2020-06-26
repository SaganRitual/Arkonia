import GameplayKit

extension Stepper {
    func colorize(_ onComplete: @escaping () -> Void) {
        SceneDispatch.shared.schedule { [unowned self] in
            self.colorize_()
            onComplete()
        }
    }
}

extension Stepper {
    private func colorize_() {
        Debug.log(level:204) { "Colorize \(name)" }

        if Arkonia.debugColorIsEnabled {
            Debug.debugColor(self, .brown, .brown)
        } else {
            setNoseColor()
        }

        setThoraxScale()

        let babyBumpShouldBeShowing =
            (metabolism.sporangium?.oxygenStore.level ?? 0) > 0

        switch (babyBumpShouldBeShowing, babyBumpIsShowing) {
        case (true, false):
            lookPregnant()
            babyBumpIsShowing = true

        case (false, true):
            lookNotPregnant()
            babyBumpIsShowing = false

        default: break
        }
    }

    private func setNoseColor() {
        nose.colorBlendFactor = 1 - metabolism.asphyxiation
    }

    private func setThoraxScale() {
        let m = metabolism
        let effectiveMass = m.mass - (m.embryo?.mass ?? 0)
        let scale = log(effectiveMass + 1)
        thorax.setScale(Arkonia.arkonScaleFactor * scale / Arkonia.zoomFactor)
    }

    private func lookNotPregnant() {
        nose.setScale(Arkonia.noseScaleFactor)
    }

    private func lookPregnant() {
        let m = metabolism
        let f: CGFloat = m.sporangium?.fatStore?.fullness ?? 0.25
        let s: CGFloat = Arkonia.arkonScaleFactor * Arkonia.noseScaleFactor *
            Arkonia.zoomFactor * f

        nose.yScale = s
        nose.xScale = s
    }
}
