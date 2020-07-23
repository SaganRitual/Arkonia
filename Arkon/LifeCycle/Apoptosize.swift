import SpriteKit

extension Stepper {
    func apoptosize(disengageAll: Bool) {
        Debug.debugColor(self, .brown, .green)

        mainDispatch { apoptosize_A() }

        func apoptosize_A() {
            // Ugly. We tell the cell we're gone ahead of time so the
            // lock releasing below can redeploy anyone who's on the
            // defer queue waiting for me to move so they can land in the cell.
            // Think of a cleaner mechanism
            let currentCell = spindle.gridCell!
            spindle.vacateCurrentCell(iHaveTheLiveConnection: true)

            if disengageAll {
                Debug.log(level: 215) { "apoptosize_A.0 \(AKName(name))" }
                sensorPad.disengageFullSensorPad()
                currentCell.lock.releaseLock(true)
            } else {
                Debug.log(level: 215) { "apoptosize_A.1 \(AKName(name))" }
                spindle.sensorPad.refractorizeShuttle(jumpSpec)
            }

            net.release(apoptosize_B)
        }

        func apoptosize_B() { SceneDispatch.shared.schedule(apoptosize_C) }

        func apoptosize_C() {
            releaseSprites()
            apoptosize_D()
        }

        func apoptosize_D() {
            // I have to make sure I destruct on the census queue, because
            // it holds a weak pointer to me, so it will know when I'm gone
            let u = Unmanaged<Stepper>.passRetained(self)
            Census.dispatchQueue.async { u.release() }
        }
    }

    func releaseSprites() {
        SpriteFactory.shared.teethPool.releaseSprite(tooth)
        SpriteFactory.shared.nosesPool.releaseSprite(nose)
        SpriteFactory.shared.arkonsPool.releaseSprite(thorax)
    }
}
