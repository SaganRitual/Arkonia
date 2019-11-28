import Dispatch

final class Disengage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Disengage() \(six(scratch.stepper?.name))", level: 3)
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    static func iOwnTheGridCell(_ gridCellConnector: SafeConnectorProtocol?) -> Bool {
        if let cell = gridCellConnector as? SafeCell {
            return cell.iOwnTheGridCell
        }

        if let grid = gridCellConnector as? SafeSenseGrid,
            let cell = grid.cells[0]
        {
            return cell.iOwnTheGridCell
        }

        if let stage = gridCellConnector as? SafeStage {
            return stage.toCell.iOwnTheGridCell
        }

        return false
    }

    func launch_() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let unsafeCell = st.gridCell else { fatalError() }

        Log.L.write("Disengage.launch_ \(six(st.name)), \(six(scratch?.stepper?.name)), \(six(unsafeCell.ownerName)), \(unsafeCell.gridPosition)", level: 5)
        precondition(unsafeCell.ownerName == st.name || ch.isAlive == false)

        unsafeCell.ownerName = nil
        ch.gridCellConnector = nil

        dp.engage()
    }

}
