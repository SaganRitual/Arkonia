import SpriteKit

final class Apoptosize: Dispatchable {
    internal override func launch() { aApoptosize() }
}

extension Apoptosize {
    func aApoptosize() { WorkItems.dismemberArkon(scratch) }
}

extension WorkItems {
    static func dismemberArkon(_ scratch: Scratchpad?) {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }
        guard let thorax = st.sprite else { fatalError() }
        guard let nose = st.nose else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

        releaseStepper(st, gc) {
            retireSprites(nose, thorax)
        }
    }

    private static func releaseStepper(
        _ stepper: Stepper, _ gridCell: GridCell, _ onComplete: @escaping () -> Void
    ) {
        Grid.shared.serialQueue.async {
            gridCell.descheduleIf(stepper)
            Stepper.releaseStepper(stepper, from: stepper.sprite!)
            onComplete()
        }
    }

    private static func retireSprites(
        _ nose: SKSpriteNode, _ thorax: SKSpriteNode
    ) {
        let action = SKAction.run {
            SpriteFactory.shared.noseHangar.retireSprite(nose)
            SpriteFactory.shared.arkonsHangar.retireSprite(thorax)
        }

        GriddleScene.shared.run(action)
    }
}
