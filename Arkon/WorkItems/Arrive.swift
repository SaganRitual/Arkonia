import Dispatch

final class Arrive: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(flags: [], block: launch_)
    }

    func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    private func launch_() { arrive() }

    func arrive() {
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

        ch.gridCellConnector = nil

        dp.metabolize(self.wiLaunch!)
    }

}
