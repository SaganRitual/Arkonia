import Dispatch

final class ReleaseStage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    func launch_() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Log.L.write("ReleaseStage.launch_ \(six(st.name))", level: 15)
        st.nose.color = .brown

        guard let stage = ch.getStageConnector() else { preconditionFailure() }

        let myLandingCell = stage.toCell
        ch.setGridConnector(myLandingCell)

        precondition(ch.getStageConnector() == nil)

        dp.metabolize()
    }
}
