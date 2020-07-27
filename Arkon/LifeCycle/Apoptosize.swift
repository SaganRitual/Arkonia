import SpriteKit

extension Stepper {
    func apoptosize(disengageAll: Bool = false) {
        Debug.debugColor(self, .brown, .green)
        assert(spindle.gridCell != nil)

        if isDyingFromParasite { dramaticDeath() }

        mainDispatch { apoptosize_A() }

        func apoptosize_A() {
            // Ugly. We tell the cell we're gone ahead of time so the
            // lock releasing below can redeploy anyone who's on the
            // defer queue waiting for me to move so they can land in the cell.
            // Think of a cleaner mechanism
            let currentCell = spindle.gridCell!
            spindle.vacateCurrentCell(iHaveTheLiveConnection: true)

            if disengageAll {
                Debug.log(level: 218) { "apoptosize_A.0 \(AKName(name))" }
                sensorPad.disengageFullSensorPad()
                currentCell.lock.releaseLock(true)
            } else {
                Debug.log(level: 218) { "apoptosize_A.1 \(AKName(name))" }
                spindle.sensorPad.refractorizeShuttle(jumpSpec)
            }

            net.release(apoptosize_B)
        }

        func apoptosize_B() { SceneDispatch.shared.schedule("apop_c", apoptosize_C) }

        func apoptosize_C() {
            releaseSprites()

            // I have to take steps to destruct on the census queue, because
            // the census holds a weak pointer to me, so it will know when I'm gone
            Census.dispatchQueue.async(execute: apoptosize_D)
        }

        func apoptosize_D() { Unmanaged<Stepper>.passRetained(self).release() }
    }

    func releaseSprites() {
        SpriteFactory.shared.teethPool.releaseSprite(tooth)
        SpriteFactory.shared.nosesPool.releaseSprite(nose)
        SpriteFactory.shared.arkonsPool.releaseSprite(thorax)
    }
}

private extension Stepper {
    func dramaticDeath() {
        SceneDispatch.shared.schedule("dramaticDeath") {
            let colorize = SKAction.colorize(with: .red, colorBlendFactor: 1, duration: 1)
            let scale = SKAction.scale(to: CGSize.zero, duration: 1)
            let group = SKAction.group([colorize, scale])
            self.thorax.run(group)
        }
    }
}
