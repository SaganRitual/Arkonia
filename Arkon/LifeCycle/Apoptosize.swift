import SpriteKit

final class Apoptosize: Dispatchable {
    internal override func launch() { apoptosize() }
}

private extension Apoptosize {
    func apoptosize() {
        Debug.log(level: 205) { "apoptosize \(stepper.name)" }
        Debug.debugColor(stepper, .brown, .green)

        Census.shared.registerDeath(stepper, apoptosize_B_disengageSensorPad)
    }

    func apoptosize_B_disengageSensorPad() {
        Debug.log(level: 205) { "apoptosize_B_disengageSensorPad.0 \(stepper.name)" }
        stepper.sensorPad.disengageGrid()

        Debug.log(level: 205) { "apoptosize_B_disengageSensorPad.1 \(stepper.name)" }
        self.apoptosize_C_releaseNet(self.stepper)
    }

    func apoptosize_C_releaseNet(_ holdingStrongReference: Stepper) {
        Debug.log(level: 205) { "apoptosize_C_releaseNet \(stepper.name)" }
        stepper.net.release(apoptosize_D_releaseStepper)
    }

    func apoptosize_D_releaseStepper() {
        SceneDispatch.shared.schedule {
            Debug.log(level: 205) { "apoptosize_D_releaseStepper \(self.stepper.name)" }
            SpriteFactory.shared.teethPool.releaseSprite(self.stepper.tooth)
            SpriteFactory.shared.nosesPool.releaseSprite(self.stepper.nose)
            SpriteFactory.shared.arkonsPool.releaseSprite(self.stepper.thorax)

            Grid.shared.removeArkon(self.stepper!)
        }
    }
}
