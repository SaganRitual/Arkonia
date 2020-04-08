class CellSenseGrid: CustomDebugStringConvertible {
    static let nilKey = NilKey()

    var cells = [GridCellProtocol]()
    lazy var debugDescription: String = { cells[0].debugDescription }()

    init(from center: GridCell, by cGridlets: Int, block: AKPoint, _ catchDumbMistakes: DispatchQueueID) {
        assert(center.ownerName == center.stepper?.name)

        // The following loop needs to be atomic relative to the arkons grid,
        // we want no interference from anyone else trying to get our squares
        assert(catchDumbMistakes == .arkonsPlane)

        cells = [center] + (1..<cGridlets).map { index in
            let position = center.getGridPointByIndex(index)

            if position == block { return CellSenseGrid.nilKey }
            guard let cell = GridCell.atIf(position) else { return CellSenseGrid.nilKey }

            // The cell hed better not have my name on it already
            assert(center.ownerName != cell.ownerName)

            let lockType: GridCell.RequireLock = index > Arkonia.cMotorGridlets ? .cold : .degradeToCold

            guard let lock = cell.lock(require: lockType, ownerName: center.ownerName, catchDumbMistakes)
                else { fatalError() }

            return lock
        }

        #if DEBUG
        for c in cells {
            assert((c is GridCell) == (c.ownerName == center.ownerName))
            assert(((c as? GridCell)?.isLocked ?? false) || !(c is GridCell))
        }
        #endif
    }

    // Release the locks on all hot cells except the from/to cells for the shuttle,
    // and let go of everything, so we don't have any strong references hanging around
    func reset(keep: GridCell, _ catchDumbMistakes: DispatchQueueID) {
        for cell in cells.dropFirst() where cell.gridPosition != keep.gridPosition {
            guard let hot = cell as? GridCell else { continue }
            Debug.log(level: 167) { "Release hot \(hot.gridPosition) tenant \(six(hot.stepper?.name)) owner \(six(hot.ownerName))" }
            hot.releaseLock(catchDumbMistakes)
        }

        cells.removeAll(keepingCapacity: true)
    }

    func getRandomEmptyHotKey() -> GridCell? {
        return cells.dropFirst().compactMap({ $0 as? GridCell }).filter({ $0.stepper == nil }).randomElement()
    }
}
