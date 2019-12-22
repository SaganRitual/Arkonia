import SpriteKit

final class Apoptosize: Dispatchable {
    internal override func launch() { aApoptosize() }
}

extension Apoptosize {
    func aApoptosize() {
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }
        guard let sp = st.sprite else { fatalError() }
        guard let no = st.nose else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

        let action = SKAction.run {
            assert(Display.displayCycle == .actions)
            if ch.isApoptosizing { return }
            ch.isApoptosizing = true

            gc.descheduleIf(st)
            sp.removeAllActions()

            SpriteFactory.shared.noseHangar.retireSprite(no)
            SpriteFactory.shared.arkonsHangar.retireSprite(sp)

            Log.L.write("Apoptosize(\(six(st.name)))", level: 63)
            Grid.shared.serialQueue.async {
                Log.L.write("Apoptosize2(\(six(st.name)))", level: 63)
                Stepper.releaseStepper(st, from: sp)
                Log.L.write("Apoptosize3(\(six(st.name)))", level: 59)
            }
        }

        GriddleScene.arkonsPortal.run(action)
    }
}
