class CellSenseGrid: CustomDebugStringConvertible {
    static let nilKey = NilKey()

    lazy var debugDescription: String = { cells[0].debugDescription }()

    var cells = [GridCellProtocol]()
    var ownerName: ArkonName

    init(from center: GridCell, by cGridlets: Int, block: AKPoint, _ catchDumbMistakes: DispatchQueueID) {
        hardAssert(center.ownerName == center.stepper?.name)
        self.ownerName = center.ownerName

        // The following loop needs to be atomic relative to the arkons grid,
        // we want no interference from anyone else trying to get our squares
        hardAssert(catchDumbMistakes == .arkonsPlane)

        cells = [center] + (1..<cGridlets).map { index in
            let position = center.getGridPointByIndex(index)

            if position == block { return CellSenseGrid.nilKey }
            guard let cell = GridCell.atIf(position) else { return CellSenseGrid.nilKey }

            Debug.log(level: 168) { "CellSenseGrid \(index), \(position) tenant \(six(cell.stepper?.name)) owner \(six(self.ownerName))" }

            // The cell hed better not have my name on it already
            hardAssert(self.ownerName != cell.ownerName)

            let lockType: GridCell.RequireLock = index > Arkonia.cMotorGridlets ? .cold : .degradeToCold

            let lock = (cell.lock(require: lockType, ownerName: self.ownerName, catchDumbMistakes))!
            return lock
        }

        #if DEBUG
        for c in cells {
            hardAssert((c is GridCell) == (c.ownerName == center.ownerName))
            hardAssert(((c as? GridCell)?.isLocked ?? false) || !(c is GridCell))
        }
        #endif
    }

    // Release the locks on all hot cells except the from/to cells for the shuttle,
    // and let go of everything, so we don't have any strong references hanging around
    func reset(keep: GridCell? = nil, _ catchDumbMistakes: DispatchQueueID) {

        let hotKeys: [(Int, GridCell)] = zip(1..., cells.dropFirst()).compactMap {
            pair in let (ss, cell) = pair

            // Skip the keeper, if there is one
            if let k = keep, cell.gridPosition == k.gridPosition { return nil }
            // Ignore anything cold
            guard let hotCell = cell as? GridCell else { return nil }

            // As of 2020.04.08, there's only one way we'll get here and find
            // that the owner names don't match: when we've just now spawned and
            // transferred that cell to the offspring. Any other time, we should
            // fall through here, because these are our hot keys
            let offspringOwnsThisCell = (hotCell.ownerName != self.ownerName)
            if offspringOwnsThisCell { return nil }

            return (ss, hotCell)
        }

        hotKeys.forEach {
            pair in let (ss, hotCell) = pair

            Debug.log(level: 168) { "Release hot \(hotCell.gridPosition) tenant \(six(hotCell.stepper?.name)) owner \(six(self.ownerName))" }

            hotCell.releaseLock(catchDumbMistakes)

            // Superstitious debugging -- this shouldn't matter, because we're
            // about to delete the array anyway, but I'm looking for poltergeists now
            cells[ss] = CellSenseGrid.nilKey
        }

        Debug.log(level: 169) { "SenseGrid post-reset for \(self.ownerName) \(cells.compactMap { ($0 is NilKey) ? nil : "\($0):\(type(of: $0))" })" }

        hardAssert(cells.filter({ $0.ownerName == self.ownerName }).count <= 2)
        cells.removeAll(keepingCapacity: true)
    }

    func setupBirthingCell(for embryoName: ArkonName) -> GridCell? {
        let pairs: [(Int, GridCell)] = zip(1..., cells.dropFirst()).compactMap({ pair in let (ss, coldCell) = pair
            if let hotCell = coldCell as? GridCell, hotCell.stepper == nil { return (ss, hotCell) }
            return nil
        })

        // If there's nowhere for my offspring to be born, I guess I'll have to eat him
        guard let (ss, birthingCell) = pairs.randomElement() else { return nil }

        Debug.log(level: 168) { "setupBirthingCell ss \(ss), cell \(birthingCell.gridPosition), owned by \(birthingCell.ownerName)" }

        // Newborn takes the hot cell
        birthingCell.ownerName = embryoName

        // I convert my hot cell to a cold key
        cells[ss] = ColdKey(for: birthingCell)

        return birthingCell
    }
}
