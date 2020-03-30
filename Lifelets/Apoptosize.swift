import SpriteKit

final class Apoptosize: Dispatchable {
    internal override func launch() { dismemberArkon() }
}

extension Apoptosize {
    private func dismemberArkon() {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log(level: 156) { "Apoptosize \(six(st.name))" }

        guard let thorax = st.sprite else { fatalError() }
        guard let nose = st.nose else { fatalError() }

        func a() { Census.shared.registerDeath(st, b) }
        func b() { Grid.arkonsPlaneQueue.async(execute: d) }
//        func c() { releaseStepper(d) }

        func d() {
            // If another arkon just ate me, I won't have a grid cell any more
            if let gc = st.gridCell { gc.stepper = nil }

            releaseStepper()
            releaseSprites(nose, thorax)
        }

        a()
    }

    private func releaseSprites(_ nose: SKSpriteNode, _ thorax: SKSpriteNode) {
        SceneDispatch.schedule {
            Debug.log(level: 102) { "Apoptosize release sprites" }
            SpriteFactory.shared.nosesPool.releaseSprite(nose)
            SpriteFactory.shared.arkonsPool.releaseSprite(thorax)
        }
    }

    private func releaseStepper() {
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }

        // If another arkon just ate me, I won't have a grid cell any more
        st.gridCell?.descheduleIf(st)
        if let ek = ch.engagerKey as? HotKey { ek.releaseLock() }
        Stepper.releaseStepper(st, from: st.sprite!)
    }
}
