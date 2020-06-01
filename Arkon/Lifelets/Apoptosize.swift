import SpriteKit

final class Apoptosize: Dispatchable {
    internal override func launch() { dismemberArkon() }
}

extension Apoptosize {
    private func dismemberArkon() {
        Debug.debugColor(scratch.stepper, .brown, .green)
        Debug.log(level: 187) { "Apoptosize.0 \(six(scratch.stepper.name))" }

        Census.shared.registerDeath(scratch.stepper, releaseNet)
    }

    private func releaseNet() {
        Debug.log(level: 187) { "Apoptosize.1 \(six(scratch.stepper.name))" }
        scratch.stepper.net.release(catchDumbMistakes: .net, releaseStepper_)
    }

    private func releaseStepper_() {
        Debug.log(level: 187) { "Apoptosize.2 \(six(scratch.stepper.name))" }
        releaseStepper { self.releaseSprites($0.sprite, $0.nose) }
    }

    private func releaseSprites(_ thorax: SKSpriteNode, _ nose: SKSpriteNode) {
        SceneDispatch.shared.schedule {
            Debug.log(level: 187) { "Apoptosize.3 release sprites" }

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
            if let gc = self.scratch.stepper.gridCell { gc.stepper = nil }

            let finalStrongReference = self.scratch.stepper!

            // If another arkon just ate me, I won't have a grid cell any more
            self.scratch.stepper.gridCell?.descheduleIf(self.scratch.stepper, catchDumbMistakes)
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
