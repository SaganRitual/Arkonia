import Dispatch

final class Arrive: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Arrive()", select: 3)
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(flags: [], block: launch_)
    }

    func launch() {
        Log.L.write("Arrive.launch", select: 3)
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    private func launch_() { arrive() }

    func arrive() {
        Log.L.write("Arrive.launch_", select: 3)
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }

        switch ch.stage.to.contents {
        case .arkon: dp.parasitize(wiLaunch!)
        case .manna: graze()
        default: fatalError()
        }
    }
}

extension Arrive {

    func graze() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }

        guard let sprite = ch.stage.to.sprite else { fatalError() }
        guard let manna = sprite.getManna() else { fatalError() }

        let harvested = manna.harvest()

        st.metabolism.absorbEnergy(harvested)
        st.metabolism.inhale()

        MannaCoordinator.shared.beEaten(sprite)

        dp.releaseStage(self.wiLaunch!)
    }

}
