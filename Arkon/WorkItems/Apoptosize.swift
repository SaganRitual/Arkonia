import SpriteKit

final class Apoptosize: Dispatchable {
    internal override func launch_() { aApoptosize() }
}

extension Apoptosize {
    func aApoptosize() {
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }
        guard let sp = st.sprite else { fatalError() }
        guard let no = st.nose else { fatalError() }

        precondition(ch.isApoptosizing == false)

        let action = SKAction.run {
            assert(Display.displayCycle == .actions)
            if ch.isApoptosizing { return }
            ch.isApoptosizing = true

            no.color = .red
            sp.removeAllActions()

            Larva.Constants.spriteFactory.noseHangar.retireSprite(no)
            Larva.Constants.spriteFactory.arkonsHangar.retireSprite(sp)

            Grid.shared.serialQueue.async {
                Stepper.releaseStepper(st, from: sp)
            }
        }

        GriddleScene.arkonsPortal.run(action)
    }
}
