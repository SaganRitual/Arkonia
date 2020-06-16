import SpriteKit

final class Apoptosize: Dispatchable {
    internal override func launch() { apoptosize() }
}

private extension Apoptosize {
    func apoptosize() {
        Debug.log(level: 191) { "Apoptosize.dismemberArkon" }
        Debug.debugColor(stepper, .brown, .green)

        Census.shared.registerDeath(stepper, apoptosize_B_disengageSensorPad)
    }

    func apoptosize_B_disengageSensorPad() {
        let pc = stepper.net.netStructure.sensorPadCCells
        Ingrid.shared.disengageSensorPad(stepper.sensorPad, padCCells: pc)
            { self.apoptosize_C_releaseNet(self.stepper) }
    }

    func apoptosize_C_releaseNet(_ holdingStrongReference: Stepper) {
        stepper.net.release(apoptosize_D_releaseStepper)
    }

    func apoptosize_D_releaseStepper() {
        SceneDispatch.shared.schedule {
            SpriteFactory.shared.teethPool.releaseSprite(self.stepper.tooth)
            SpriteFactory.shared.nosesPool.releaseSprite(self.stepper.nose)
            SpriteFactory.shared.arkonsPool.releaseSprite(self.stepper.thorax)

            Ingrid.shared.releaseArkon(self.stepper!)
        }
    }
}
