import Dispatch

final class Engage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?
    var counter = 0

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(block: launch_)
        Log.L.write("Engage \(six(scratch.stepper?.name)), \(scratch.getStageConnector()?.toCell.gridPosition ?? AKPoint.zero)", level: 28)
    }

    func launch_() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

        guard let lockedCell = gc.lock(require: false) else {
            Log.L.write("Engage.launch1 \(six(st.name)), \(ch.getStageConnector()?.toCell.gridPosition ?? AKPoint.zero)", level: 28)
            ch.isAwaitingWakeup = true
            return
        }

        Log.L.write("Engage.launch2 \(six(st.name)), \(ch.getStageConnector()?.toCell.gridPosition ?? AKPoint.zero)", level: 28)

        let cellConnector = SafeCell(from: lockedCell)
        ch.setGridConnector(cellConnector)

        ch.worldStats = World.stats.copy()

        dp.funge()
        Log.L.write("Engage.launch3 \(six(st.name)), \(ch.getStageConnector()?.toCell.gridPosition ?? AKPoint.zero)", level: 28)
    }
}
