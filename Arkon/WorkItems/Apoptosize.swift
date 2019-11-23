import SpriteKit

final class Apoptosize: Dispatchable {
    var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Apoptosize()", select: 3)
        if !scratch.isApoptosizing { self.scratch = scratch }
        self.wiLaunch = DispatchWorkItem(flags: [], block: launch_)
    }

    func launch() {
        Log.L.write("Apoptosize.launch", select: 3)
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    private func launch_() { aApoptosize() }
}

extension Apoptosize {
    func aApoptosize() {
        Log.L.write("Apoptosize.launch_", select: 3)
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

            Grid.shared.concurrentQueue.sync(flags: .barrier) {
                Log.L.write("Release stepper \(six(st.name))")
                Stepper.releaseStepper(st, from: sp)
            }
        }

        GriddleScene.arkonsPortal.run(action)
    }
}
