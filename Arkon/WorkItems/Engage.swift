import Dispatch

final class Engage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?
    var counter = 0

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    func launch_() {
        guard let (_, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gridCell = st.gridCell else { fatalError() }

        let safeCell = gridCell.engage_(st.name, false)
        if safeCell.iOwnTheGridCell {
            Log.L.write("lock for \(six(st.name)) at \(gridCell)", level: 15)
            self.onLock(safeCell)
        } else {
            Log.L.write("no lock for \(six(st.name)) at \(gridCell)", level: 15)
        }

        dp.funge()
    }

    func onLock(_ safeCell: SafeCell) {
        precondition(counter == 0)
        defer { counter -= 1 }
        counter += 1

        guard let (ch, _, _) = scratch?.getKeypoints() else { fatalError() }
        precondition(ch.gridCellConnector == nil)

        ch.worldStats = World.stats.copy()

        ch.gridCellConnector =
            SafeSenseGrid(from: safeCell, by: ArkoniaCentral.cMotorGridlets)
    }
}
