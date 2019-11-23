import Dispatch

class ReleaseStage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("ReleaseStage()", select: 3)
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(flags: [], block: launch_)
    }

    func launch() {
        Log.L.write("ReleaseStage.launch", select: 3)
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    func launch_() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }

        let myLandingCell = SafeCell.releaseStage(ch.stage)
        Log.L.write("ReleaseStage.launch_\(six(myLandingCell.ownerName))", select: 3)

        ch.gridCellConnector = myLandingCell
        dp.metabolize(wiLaunch!)
    }
}
