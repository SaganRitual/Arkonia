import SpriteKit

final class Apoptosize: Dispatchable {
    internal override func launch() { apoptosize() }
}

private extension Apoptosize {
    func apoptosize() {
        Debug.log(level: 191) { "Apoptosize.dismemberArkon" }
        Debug.debugColor(stepper, .brown, .green)

        Census.shared.registerDeath(stepper, disengageSensorPad)
    }

    func disengageSensorPad() {
        let padCCells = stepper.net.netStructure.cCellsWithinSenseRange
        Ingrid.shared.disengageSensorPad(
            stepper.sensorPad, padCCells: padCCells, keepTheseCells: [], releaseNet
        )
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
