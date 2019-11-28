import Dispatch

final class ReleaseStage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("ReleaseStage()", level: 3)
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    func launch_() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }

        defer { dp.metabolize() }

        guard let stage = ch.getStageConnector() else { return }

        Log.L.write("cello", level : 10)
        let myLandingCell = SafeCell.releaseStage(stage)
        Log.L.write("cellp", level : 10)

        ch.gridCellConnector = myLandingCell
    }
}
