import Dispatch

class ReleaseStage: Dispatchable {
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

    func launch_() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }

        let myLandingCell = SafeCell.collapseStage(ch.stage)
        SafeCell.transferCellLock(from: ch.stage.to, to: myLandingCell)

        ch.gridCellConnector = myLandingCell
        dp.metabolize(wiLaunch!)
    }
}
