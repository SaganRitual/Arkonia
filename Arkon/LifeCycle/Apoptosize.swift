import SpriteKit

extension Stepper {
    func apoptosize(disengageAll: Bool) {
        Debug.debugColor(self, .brown, .green)

        Census.shared.registerDeath(self) { apoptosize_A() }

        func apoptosize_A() { MainDispatchQueue.async(execute: apoptosize_B) }

        func apoptosize_B() {
            // Ugly. We tell the cell we're gone ahead of time so the
            // lock releasing below can redeploy anyone who's on the
            // defer queue waiting for me to move so they can land in the cell.
            // Think of a cleaner mechanism
            let currentCell = spindle.gridCell!
            spindle.vacateCurrentCell(iHaveTheLiveConnection: true)

            if disengageAll {
                Debug.log(level: 215) { "apoptosize_C.0 \(AKName(name))" }
                sensorPad.disengageFullSensorPad()
                currentCell.lock.releaseLock(true)
            } else {
                Debug.log(level: 215) { "apoptosize_C.1 \(AKName(name))" }
                spindle.sensorPad.refractorizeShuttle(jumpSpec)
            }

            net.release(apoptosize_C)
        }

        func apoptosize_C() { SceneDispatch.shared.schedule(releaseSprites) }
    }

    func releaseSprites() {
        SpriteFactory.shared.teethPool.releaseSprite(tooth)
        SpriteFactory.shared.nosesPool.releaseSprite(nose)
        SpriteFactory.shared.arkonsPool.releaseSprite(thorax)
    }
}
