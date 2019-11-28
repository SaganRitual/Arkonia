import Dispatch

final class Arrive: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Arrive()", level: 3)
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    private func launch_() { arrive() }

    func arrive() {
        Log.L.write("Arrive.launch_ \(six(scratch?.stepper?.name))", level: 15)
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }

        switch ch.getStageConnector(require: true)?.toCell.contents {
        case .arkon: dp.parasitize()
        case .manna: graze()
        default: fatalError()
        }
    }
}

extension Arrive {

    func graze() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }

        guard let sprite = ch.getStageConnector()?.toCell.sprite else { fatalError() }
        guard let manna = sprite.getManna() else { fatalError() }

        let harvested = manna.harvest()

        st.metabolism.absorbEnergy(harvested)
        st.metabolism.inhale()

        MannaCoordinator.shared.beEaten(sprite)

        dp.releaseStage()
    }

}
