import SpriteKit

extension Stepper {
    func apoptosize() {
        Debug.debugColor(self, .brown, .green)

        func apoptosize_A() { Census.shared.registerDeath(self, apoptosize_B) }
        func apoptosize_B() { MainDispatchQueue.async(execute: apoptosize_C) }
        func apoptosize_C() { sensorPad.disengageSensorPad(apoptosize_D) }
        func apoptosize_D() { net.release(apoptosize_E) }
        func apoptosize_E() { SceneDispatch.shared.schedule(apoptosize_F) }
        func apoptosize_F() { releaseSprites(apoptosize_G) }
        func apoptosize_G() { MainDispatchQueue.async(execute: apoptosize_H) }

        func apoptosize_H() {
            // This releases the last strong ref; self should deinit now
            Grid.detachArkonFromGrid(at: sensorPad.centerAbsoluteIndex!)
        }

        MainDispatchQueue.async(execute: apoptosize_A)
    }

    func releaseSprites(_ onComplete: @escaping () -> Void) {
        SpriteFactory.shared.teethPool.releaseSprite(tooth)
        SpriteFactory.shared.nosesPool.releaseSprite(nose)
        SpriteFactory.shared.arkonsPool.releaseSprite(thorax)
        onComplete()
    }
}
