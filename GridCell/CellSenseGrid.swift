class CellSenseGrid: CustomDebugStringConvertible {
    var cells = [GridCellKey]()
    var centerName = ""
    var debugDescription = ""

    static func makeCellSenseGrid(
        from center: HotKey, by cGridlets: Int, block: AKPoint,
        _ onComplete: @escaping (CellSenseGrid) -> Void
    ) {
        Grid.shared.serialQueue.async {
            let senseGrid = CellSenseGrid(from: center, by: cGridlets, block: block)
            onComplete(senseGrid)
        }
    }

    private init(from center: HotKey, by cGridlets: Int, block: AKPoint) {
        self.postInit(from: center, by: cGridlets, block: block)
    }

    private func postInit(from center: HotKey, by cGridlets: Int, block: AKPoint) {
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

            guard let lock = cell.getLock(for: stepper, lockType, false)
                else { fatalError() }

            return lock
        }
    }
}
