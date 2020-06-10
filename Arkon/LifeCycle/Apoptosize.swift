import SpriteKit

final class Apoptosize: Dispatchable {
    internal override func launch() { dismemberArkon() }
}

private extension Apoptosize {
    func dismemberArkon() {
        Debug.log(level: 191) { "Apoptosize.dismemberArkon" }
        Debug.debugColor(stepper, .brown, .green)

        Census.shared.registerDeath(stepper, releaseNet)
    }

    func releaseNet() {
        stepper.net.release(releaseStepper_)
    }

    func releaseStepper_() {
        releaseStepper { self.releaseSprites($0.sprite, $0.nose, $0.tooth) }
    }

    func releaseSprites(_ thorax: SKSpriteNode, _ nose: SKSpriteNode, _ tooth: SKSpriteNode) {
        SceneDispatch.shared.schedule {
            SpriteFactory.shared.teethPool.releaseSprite(tooth)
            SpriteFactory.shared.nosesPool.releaseSprite(nose)
            SpriteFactory.shared.arkonsPool.releaseSprite(thorax)
        }
    }

    func releaseStepper(_ onComplete: @escaping (Stepper) -> Void) {

        Stepper.releaseStepper(stepper, from: stepper.sprite!)

        // This is the last strong reference to the stepper. Once the
        // caller is finished with the variable, the stepper should destruct
        onComplete(stepper)
    }
}
