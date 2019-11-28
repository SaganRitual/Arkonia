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

        defer { dp.metabolize() }

        guard let stage = ch.getStageConnector() else { return }

        let myLandingCell = SafeCell.releaseStage(stage)

        ch.gridCellConnector = myLandingCell
    }
}
