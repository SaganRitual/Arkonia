import Foundation

typealias UnsafeCellConnectors = UnsafeMutablePointer<IngridCellConnector?>

class SensorPad {
    let cCells: Int
    var centerAbsoluteIndex = 0
    let unsafeCellConnectors: UnsafeCellConnectors

    static func makeSensorPad(_ cCells: Int) -> SensorPad { return .init(cCells) }

    private init(_ cCells: Int) {
        self.cCells = cCells

        self.unsafeCellConnectors = .allocate(capacity: cCells)
        self.unsafeCellConnectors.initialize(repeating: nil, count: cCells)
    }

    func localIndexToAbsolute(_ localIx: Int) -> Int { unsafeCellConnectors[localIx]!.absoluteIndex }
}

extension SensorPad {
    func invalidateCell(_ localPadIx: Int) -> Int? {
        // If we don't have a hot connection to the cell, we don't
        // need to do anything to it
        if thePad[localPadIx]!.coreCell == nil { return nil }

        let absoluteCellIx = localIndexToAbsolute(localPadIx)

        // Invalidate the caller's pad so he won't think he can just
        // come back and mess about the place
        thePad[localPadIx] = IngridCellConnector(absoluteCellIx)

        return absoluteCellIx
    }

    func invalidateToShuttle(_ keepLocalIndex: Int) -> [Int] {
        return (1..<cCells).compactMap {
            $0 == 0 || $0 == keepLocalIndex ? nil : invalidateCell($0)
        }
    }

    // Release all the cells in the sensor pad that won't be involved in the
    // jump. The "shuttle" refers to the two cells remaining, which will always
    // be the center, at [0], and some other locked cell in the pad
    func pruneToShuttle(_ keepLocalIndex: Int) {
        let absoluteIndexesToUnlock = invalidateToShuttle(keepLocalIndex)
        Ingrid.shared.unlockCells(absoluteIndexesToUnlock)
    }
}

extension SensorPad {
    func disengageGrid() {
        let toUnlockAbsoluteIndexes: [Int] = (0..<cCells).compactMap {
            return thePad[$0]!.coreCell?.absoluteIndex
        }

        Ingrid.shared.unlockCells(toUnlockAbsoluteIndexes)
    }

    func engageBirthCell(center absoluteIndex: Int, _ onComplete: @escaping () -> Void) {
        let mapper = SensorPadMapper(1, absoluteIndex, thePad, onComplete)
        Ingrid.shared.engageGrid(mapper)
    }

    func firstFullGridEngage(
        center absoluteIndex: Int, _ lockCompletionCallback: @escaping () -> Void
    ) {
        let alreadyLockedCell = Ingrid.shared.cellAt(absoluteIndex)

        let mapper = mapSensorPadToGrid(absoluteIndex, cCells, true, lockCompletionCallback)

        let p = Ingrid.absolutePosition(of: absoluteIndex)
        Debug.log(level: 203) { "firstFullGridEngage at abs \(absoluteIndex) \(p)" }

        thePad[0] = IngridCellConnector(alreadyLockedCell)
        Ingrid.shared.engageGrid(mapper, centerCellIsAlreadyLocked: true)
    }

    func engageGrid(center absoluteIndex: Int, _ onComplete: @escaping () -> Void) {
        let mapper = mapSensorPadToGrid(absoluteIndex, cCells, false, onComplete)

        let p = Ingrid.absolutePosition(of: mapper.centerAbsoluteIndex)
        Debug.log(level: 203) { "engageGrid at abs \(absoluteIndex) \(p)" }

        Ingrid.shared.engageGrid(mapper) // completion callback is inside the mapper
    }

    private func mapSensorPadToGrid(
        _ centerAbsoluteIndex: Int, _ cCells: Int,
        _ centerCellIsAlreadyLocked: Bool,
        _ lockCompletionCallback: @escaping () -> Void
    ) -> SensorPadMapper {

        let start = centerCellIsAlreadyLocked ? 1 : 0

        Debug.log(level: 203) { "mapSensorPadToGrid center is \(centerAbsoluteIndex), start at localIx \(start)" }

        for ss in start..<cCells {
            var p = Ingrid.shared.indexer.getGridPointByLocalIndex(
                center: centerAbsoluteIndex, targetIndex: ss
            )

            var vp: CGPoint?    // Virtual target for teleportation

            if let q = Ingrid.shared.core.correctForDisjunction(p)
                { vp = p.asPoint(); p = q }

            let cell = Ingrid.shared.cellAt(p)

            Debug.log(level: 203) { "requesting cell at \(cell.absoluteIndex) \(cell.gridPosition) (local \(ss))" }
            thePad[ss] = IngridCellConnector(cell, vp)
        }

        return SensorPadMapper(
            cCells, centerAbsoluteIndex, thePad, lockCompletionCallback
        )
    }
}
