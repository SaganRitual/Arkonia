import Dispatch

class Engage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(flags: .barrier, block: launch_)
    }

    func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    func launch_() {
        guard let (_, _, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gridCell = st.gridCell else { fatalError() }

        guard let lockedCell = gridCell.engage_(st.name, false)
            else { return }

        self.onLock(lockedCell)
    }

    func onLock(_ myGridCell: SafeCell) {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }

        ch.gridCellConnector = myGridCell
        ch.worldStats = World.stats.copy()

        reserveGridPoints()
        dp.plot(wiLaunch)
    }
}

extension Engage {
    func reserveGridPoints() {
        guard let ch = scratch else { fatalError() }

        let oldGcc = ch.safeCell
        assert(oldGcc.owner != nil)

        let sc = SafeSenseGrid(from: oldGcc, by: ArkoniaCentral.cMotorGridlets)
        ch.gridCellConnector = sc
    }
}
