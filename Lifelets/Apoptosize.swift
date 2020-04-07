import SpriteKit

final class Apoptosize: Dispatchable {
    internal override func launch() { dismemberArkon() }
}

extension Apoptosize {
    private func dismemberArkon() {
        Debug.log(level: 157) { "Apoptosize \(six(scratch.stepper.name))" }

        Census.shared.registerDeath(scratch.stepper, release)
    }

    private func release() {
        if let gc = scratch.stepper.gridCell { gc.stepper = nil }

        releaseStepper(releaseSprites)
    }

    private func releaseSprites(_ stepper: Stepper) {
        SceneDispatch.schedule {
            guard let thorax = stepper.sprite else { fatalError() }
            guard let nose = stepper.nose else { fatalError() }

            Debug.log(level: 102) { "Apoptosize release sprites" }

            SpriteFactory.shared.nosesPool.releaseSprite(nose)
            SpriteFactory.shared.arkonsPool.releaseSprite(thorax)
        }
    }

    private func releaseStepper(_ onComplete: @escaping (Stepper) -> Void) {
        Grid.arkonsPlaneQueue.async {
            let finalStrongReference = self.scratch.stepper!

            // If another arkon just ate me, I won't have a grid cell any more
            self.scratch.stepper.gridCell?.descheduleIf(self.scratch.stepper)
            assert(self.scratch.engagerKey == nil)
//            if let ek = self.scratch.engagerKey as? GridCell { ek.releaseLock() }
            Stepper.releaseStepper(self.scratch.stepper, from: self.scratch.stepper.sprite!)

            // This is the last strong reference to the stepper. Once the
            // caller is finished with the variable, the stepper should destruct
            onComplete(finalStrongReference)
        }
    }
}
