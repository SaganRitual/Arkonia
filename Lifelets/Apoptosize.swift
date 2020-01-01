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
        Log.L.write("Apoptosize \(six(st.name))", level: 71)
        guard let thorax = st.sprite else { fatalError() }
        guard let nose = st.nose else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

        scratch?.stepper?.netDisplay = nil
        Census.shared.registerDeath(st) {
            releaseStepper(st, gc) {
                gc.contents = .nothing
                gc.sprite = nil

                retireSprites(nose, thorax)
            }
        }
    }

    private static func releaseStepper(
        _ stepper: Stepper, _ gridCell: GridCell, _ onComplete: @escaping () -> Void
    ) {
        Grid.serialQueue.async {
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
