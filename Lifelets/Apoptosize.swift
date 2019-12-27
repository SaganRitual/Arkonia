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

        precondition(st.name == sp.name)

        precondition((sp.getStepper(require: false)?.name ?? "") == sp.name)
        precondition((sp.getStepper(require: false)?.name ?? "") == st.name)

        Log.L.write("Apoptosize function stepper(\(six(st.name)) sprite(\(six(sp.name)))", level: 66)

        let action = SKAction.run {
            precondition("defunct-\(st.name)" == sp.name)
            assert(Display.displayCycle == .actions)
            if ch.isApoptosizing { return }
            ch.isApoptosizing = true

            gc.descheduleIf(st)
            precondition("defunct-\(st.name)" == sp.name)
            sp.removeAllActions()
            precondition("defunct-\(st.name)" == sp.name)

            SpriteFactory.shared.noseHangar.retireSprite(no)
            SpriteFactory.shared.arkonsHangar.retireSprite(sp)

            Log.L.write("Apoptosize action stepper(\(six(st.name)) sprite(\(six(sp.name)))", level: 66)
        }

        Grid.shared.serialQueue.async {
            Log.L.write("Apoptosize workitem stepper(\(six(st.name)) sprite(\(six(sp.name)))", level: 66)
            precondition(st.name == sp.name)
            precondition((sp.getStepper(require: false)?.name ?? "") == sp.name)
            Stepper.releaseStepper(st, from: sp)
            Log.L.write("Apoptosize3(\(six(st.name)))", level: 59)

            GriddleScene.shared.run(action)
        }
    }
}
