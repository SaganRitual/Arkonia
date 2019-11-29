import SpriteKit

final class Apoptosize: Dispatchable {
    var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Apoptosize()", level: 3)
        if !scratch.isApoptosizing { self.scratch = scratch }
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    private func launch_() { aApoptosize() }
}

extension Apoptosize {
    func aApoptosize() {
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }
        guard let sp = st.sprite else { fatalError() }
        guard let no = st.nose else { fatalError() }

        if ch.isApoptosizing { return }

        let action = SKAction.run {
            assert(Display.displayCycle == .actions)
            if ch.isApoptosizing { return }
            ch.isApoptosizing = true

            sp.removeAllActions()

            Wangkhi.spriteFactory.noseHangar.retireSprite(no)
            Wangkhi.spriteFactory.arkonsHangar.retireSprite(sp)

            Grid.shared.serialQueue.async {
                Stepper.releaseStepper(st, from: sp)
            }
        }

        GriddleScene.arkonsPortal.run(action)
    }
}
