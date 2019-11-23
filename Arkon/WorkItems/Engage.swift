import Dispatch

class Engage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Engage()", select: 3)
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(flags: .barrier, block: launch_)
    }

    deinit {
        Log.L.write("~Engage", select: 4)
    }

    func launch() {
        Log.L.write("Engage.launch", select: 3)
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    func launch_() {
        Log.L.write("Engage.launch_", select: 3)
        guard let (_, _, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gridCell = st.gridCell else { fatalError() }

        guard let lockedCell = gridCell.engage_(st.name, false)
            else {
                Log.L.write("Engage.engage_ missed", select: 3)
                return }

        Log.L.write("Engage.engage_ locked", select: 3)
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
        assert(oldGcc.ownerName != nil)

        let sc = SafeSenseGrid(from: oldGcc, by: ArkoniaCentral.cMotorGridlets)
        ch.gridCellConnector = sc
    }
}
