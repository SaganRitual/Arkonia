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
        let pc = stepper.net.netStructure.sensorPadCCells
        Ingrid.shared.disengageSensorPad(
            stepper.sensorPad, padCCells: pc, keepTheseCells: [0], releaseNet
        )
    }

    func releaseNet() { stepper.net.release(releaseStepper) }

    func releaseStepper() {
        SceneDispatch.shared.schedule {
            SpriteFactory.shared.teethPool.releaseSprite(self.stepper.tooth)
            SpriteFactory.shared.nosesPool.releaseSprite(self.stepper.nose)
            SpriteFactory.shared.arkonsPool.releaseSprite(self.stepper.thorax)

            // This doesn't have to happen on the scene dispatch, but it
            // needs to happen  last. It's quick enough, I think, to not
            // be a big issue running on this dispatch. I guess we'll find out
            Debug.log(level: 197) { "apoptosize.releaseStepper.0 \(six(self.stepper?.name))" }
            Ingrid.shared.arkons.releaseArkon(self.stepper!)
            Debug.log(level: 197) { "apoptosize.releaseStepper.1 \(six(self.stepper?.name))" }
        }
    }
}
