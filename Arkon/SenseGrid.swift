import Foundation

class SenseGrid: CustomDebugStringConvertible {
    static let nilKey = NilKey()

    lazy var debugDescription: String = { cells[0].debugDescription }()

    var cells: [GridCellProtocol?]
    let cCellsWithinSenseRange: Int
    let ownerName: ArkonName

    init(_ stepper: Stepper, cCellsWithinSenseRange: Int) {
        self.ownerName = stepper.name

        self.cells = [GridCellProtocol?](repeating: nil, count: cCellsWithinSenseRange)

        self.cCellsWithinSenseRange = cCellsWithinSenseRange
    }

    func assembleGrid(center: GridCell, block: AKPoint, _ catchDumbMistakes: DispatchQueueID) {
        hardAssert(center.ownerName == center.stepper?.name) { "hardAssert at \(#file):\(#line)" }

        self.cells[0] = center

        // The following loop needs to be atomic relative to the arkons grid,
        // we want no interference from anyone else trying to get our squares
        hardAssert(catchDumbMistakes == .arkonsPlane) { "hardAssert at \(#file):\(#line)" }

        for index in 1..<cCellsWithinSenseRange {
            let position = center.getGridPointByIndex(index)

            if position == block { self.cells[index] = SenseGrid.nilKey; continue }

            guard let cell = GridCell.atIf(position) else { self.cells[index] = SenseGrid.nilKey; continue }

            Debug.log(level: 168) { "CellSenseGrid \(index), \(position) tenant \(six(cell.stepper?.name)) owner \(six(self.ownerName))" }

            if self.ownerName == cell.ownerName {
                SenseGrid.checkGridIntegrity(center, cells)

                hardAssert(false) {
                    "Cell at \(position)/\(type(of: cell))"
                    + " should not have my name (\(self.ownerName))"
                    + " on it already; line number \(#line) in \(#file)"
                }
            }

            guard let lock = (cell.lock(require: .degradeToCold, ownerName: self.ownerName, catchDumbMistakes))
                else { fatalError() }

            self.cells[index] = lock
        }

        #if DEBUG
        SenseGrid.checkGridIntegrity(center, cells)
        #endif
    }

    // Release the locks on all hot cells except the from/to cells for the shuttle,
    // and let go of everything, so we don't have any strong references hanging around
    func reset(keep: GridCell? = nil, _ catchDumbMistakes: DispatchQueueID) {
        hardAssert(catchDumbMistakes == .arkonsPlane) { "Wrong dispatch queue" }

        let hotKeys: [(Int, GridCell)] = zip(1..., cells.dropFirst()).compactMap {
            pair in let (ss, cell) = pair

            // Ignore anything cold
            guard let hotCell = cell as? GridCell else { return nil }

            // Skip the keeper, if there is one
            if let k = keep, hotCell.gridPosition == k.gridPosition { return nil }

            // As of 2020.04.08, there's only one way we'll get here and find
            // that the owner names don't match: when we've just now spawned and
            // transferred that cell to the offspring. Any other time, we should
            // fall through here, because these are our hot keys
            let offspringOwnsThisCell = (hotCell.ownerName != self.ownerName)
            if offspringOwnsThisCell {
                Debug.log(level: 185) { "Resetting sense grid for \(self.ownerName); offspring \(hotCell.ownerName)(?) keeps \(hotCell.gridPosition)" }
                return nil
            }

            return (ss, hotCell)
        }

        hotKeys.forEach {
            pair in let (ss, hotCell) = pair

            Debug.log(level: 168) { "Release hot \(hotCell.gridPosition) tenant \(six(hotCell.stepper?.name)) owner \(six(self.ownerName))" }

            hotCell.releaseLock(catchDumbMistakes)

            cells[ss] = SenseGrid.nilKey    // Be tidy, in case it helps with debg
        }

        hardAssert(
            cells.filter({ (($0 as? GridCell)?.ownerName ?? ArkonName.empty) == self.ownerName }).count <= 2
        ) { "hardAssert at \(#file):\(#line)" }
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

#if DEBUG
extension SenseGrid {
    static func checkGridIntegrity(_ center: GridCell, _ cells: [GridCellProtocol?]) {
        for c in cells {
            hardAssert((c is GridCell) == (c!.ownerName == center.ownerName)) { "hardAssert at \(#file):\(#line)" }
            hardAssert(((c as? GridCell)?.isLocked ?? false) || !(c is GridCell)) { "hardAssert at \(#file):\(#line)" }

            if let cc = c as? GridCell {

                hardAssert(cc.ownerName == center.ownerName) {
                    "Hot cell in my (\(center.ownerName))"
                        + " grid has someone else's name"
                        + " (\(cc.ownerName)) on it"
                        + " \(#file):\(#line)"
                }

                hardAssert(cc.isLocked) {
                    "Hot cell in my grid has my name"
                    + " (\(center.ownerName)) but isn't locked"
                    + " \(#file):\(#line)"
                }

            } else if let cc = c {
                hardAssert(cc.ownerName != center.ownerName) {
                    "Cold cell in my grid has my name"
                        + "(\(center.ownerName)) on it \(#file):\(#line)"
                }
            }
        }
    }
}
#endif
