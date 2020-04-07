class CellSenseGrid: CustomDebugStringConvertible {
    static let nilKey = NilKey()

    var cells = [GridCellProtocol]()
    let centerName: ArkonName
    var debugDescription: String { centerName.debugDescription }

    init(from center: GridCell, by cGridlets: Int, block: AKPoint, _ catchDumbMistakes: DispatchQueueID) {
        centerName = center.ownerName
        assert(center.ownerName == center.stepper?.name)

        // The following loop needs to be atomic relative to the arkons grid,
        // we want no interference from anyone else trying to get our squares
        assert(catchDumbMistakes == .arkonsPlane)

        cells = [center] + (1..<cGridlets).map { index in
            let position = center.getGridPointByIndex(index)

            if position == block { return NilKey() }
            guard let cell = GridCell.atIf(position) else { return NilKey() }
            if index > Arkonia.cMotorGridlets { return ColdKey(for: cell) }

            let lockType: GridCell.RequireLock = index > Arkonia.cMotorGridlets ? .cold : .degradeToCold

            guard let lock = cell.lock(require: lockType, ownerName: centerName, catchDumbMistakes)
                else { fatalError() }

            return lock
        }
    }

    // Release the locks on all hot cells except the from/to cells for the shuttle,
    // and let go of everything, so we don't have any strong references hanging around
    func reset(keep: GridCell, _ catchDumbMistakes: DispatchQueueID) {
        for cell in cells.dropFirst() where cell.gridPosition != keep.gridPosition {
            (cell as? GridCell)?.releaseLock(catchDumbMistakes)
        }

        cells.removeAll(keepingCapacity: true)
    }

    func getRandomEmptyHotKey() -> GridCell? {
        return cells.dropFirst().compactMap({ $0 as? GridCell }).filter({ $0.stepper == nil }).randomElement()
    }
}
