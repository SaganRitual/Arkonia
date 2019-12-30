class CellSenseGrid: CustomDebugStringConvertible {
    var cells = [GridCellKey]()
    var centerName = ""
    var debugDescription = ""

    init(from center: HotKey, by cGridlets: Int, block: AKPoint) {
        Grid.shared.serialQueue.async {
            self.postInit(from: center, by: cGridlets, block: block)
        }
    }

    func postInit(from center: HotKey, by cGridlets: Int, block: AKPoint) {
        guard let cc = center.bell else { preconditionFailure() }
        centerName = cc.ownerName

        cells = [center] + (1..<cGridlets).map { index in
            guard let position = center.bell?.getGridPointByIndex(index)
                else { preconditionFailure() }

            if position == block { return NilKey() }
            guard let cell = GridCell.atIf(position) else { return NilKey() }
            if index > Arkonia.cMotorGridlets { return cell.coldKey! }

            let lockType: GridCell.RequireLock = index > Arkonia.cMotorGridlets ? .cold : .degradeToCold

            guard let stepper = center.sprite?.getStepper(require: false) else { fatalError() }

            guard let lock = cell.getLock(for: stepper, require: lockType)
                else { fatalError() }

            return lock
        }
    }
}
