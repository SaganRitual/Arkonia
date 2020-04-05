import SpriteKit

final class Apoptosize: Dispatchable {
    internal override func launch() { dismemberArkon() }
}

extension Apoptosize {
    private func dismemberArkon() {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log(level: 156) { "Apoptosize \(six(st.name))" }

        Census.shared.registerDeath(st, release)
    }

    private func release() {
        guard let (_, _, st) = self.scratch?.getKeypoints() else { fatalError() }
        if let gc = st.gridCell { gc.stepper = nil }

        releaseStepper(releaseSprites)
    }

    private func releaseSprites(_ st: Stepper) {
        SceneDispatch.schedule {
            guard let thorax = st.sprite else { fatalError() }
            guard let nose = st.nose else { fatalError() }

            Debug.log(level: 102) { "Apoptosize release sprites" }

            SpriteFactory.shared.nosesPool.releaseSprite(nose)
            SpriteFactory.shared.arkonsPool.releaseSprite(thorax)
        }
    }

    private func releaseStepper(_ onComplete: @escaping (Stepper) -> Void) {
        Grid.arkonsPlaneQueue.async {
            guard let (ch, _, st) = self.scratch?.getKeypoints() else { fatalError() }

            // If another arkon just ate me, I won't have a grid cell any more
            st.gridCell?.descheduleIf(st)
            if let ek = ch.engagerKey as? HotKey { ek.releaseLock() }
            Stepper.releaseStepper(st, from: st.sprite!)

            // This is the last strong reference to the stepper. Once the
            // caller is finished with the variable, the stepper should destruct
            onComplete(st)
        }
    }
}
