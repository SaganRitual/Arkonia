import SpriteKit

final class Apoptosize: Dispatchable {
    internal override func launch() { Debug.log("Apoptosize launch \(six(scratch?.name))", level: 80); aApoptosize() }
}

extension Apoptosize {
    func aApoptosize() { WorkItems.dismemberArkon(scratch) }
}

extension WorkItems {
    static func dismemberArkon(_ scratch: Scratchpad?) {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log("Apoptosize \(six(st.name))", level: 80)
        guard let thorax = st.sprite else { fatalError() }
        guard let nose = st.nose else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

        if let nd = st.netDisplay { nd.reset() }

        func a() { Debug.log("aApoptosize \(six(st.name))", level: 80); Census.shared.registerDeath(st, b) }
        func b() { Debug.log("bApoptosize \(six(st.name))", level: 80); releaseStepper(st, gc, c) }
        func c() { Debug.log("cApoptosize \(six(st.name))", level: 83); gc.setContents(to: .nothing, newSprite: nil, d) }
        func d() { Debug.log("dApoptosize \(six(st.name))", level: 80); retireSprites(nose, thorax) }

        a()
    }

    private static func releaseStepper(
        _ stepper: Stepper, _ gridCell: GridCell, _ onComplete: @escaping () -> Void
    ) {
        Substrate.serialQueue.async {
            gridCell.descheduleIf(stepper)
            Stepper.releaseStepper(stepper, from: stepper.sprite!)
            onComplete()
        }
    }

    private static func retireSprites(
        _ nose: SKSpriteNode, _ thorax: SKSpriteNode
    ) {
        SceneDispatch.schedule {
            SpriteFactory.shared.noseHangar.retireSprite(nose)
            SpriteFactory.shared.arkonsHangar.retireSprite(thorax)
        }
    }
}
