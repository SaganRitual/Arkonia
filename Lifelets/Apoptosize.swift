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

        releaseStepper { self.releaseSprites($0) }
    }

    private func releaseSprites(_ stepper: Stepper) {
        SceneDispatch.shared.schedule {
            guard let thorax = stepper.sprite else { fatalError() }
            guard let nose = stepper.nose else { fatalError() }

            Debug.log(level: 102) { "Apoptosize release sprites" }

            SpriteFactory.shared.nosesPool.releaseSprite(nose)
            SpriteFactory.shared.arkonsPool.releaseSprite(thorax)
        }
    }

    private func releaseStepper(_ onComplete: @escaping (Stepper) -> Void) {
        // Make sure it's all on the right dispatch queue
        let catchDumbMistakes = DispatchQueueID.arkonsPlane
        // If you put it on a different queue, change the above, or else
        let catchReallyDumbMistakes = Grid.arkonsPlaneQueue
        catchReallyDumbMistakes.async {
            let finalStrongReference = self.scratch.stepper!

            // If another arkon just ate me, I won't have a grid cell any more
            self.scratch.stepper.gridCell?.descheduleIf(self.scratch.stepper)
            // An ugly hack, I need to clean up the way I'm handling engager
            // keys and stuff. For now, just make sure they're all cleaned up
            // here inside the arkonsPlane lock
            self.scratch.apoptosize(catchDumbMistakes)

            Stepper.releaseStepper(
                self.scratch.stepper, from: self.scratch.stepper.sprite!,
                catchDumbMistakes
            )

            // This is the last strong reference to the stepper. Once the
            // caller is finished with the variable, the stepper should destruct
            onComplete(finalStrongReference)
        }
    }
}
