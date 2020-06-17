import Foundation

class SensorPad {
    let cCells: Int
    let thePad: UnsafeMutablePointer<IngridCellConnector?>

    var jumpTargetLocalIndex: Int?

    static func makeSensorPad(_ cCells: Int) -> SensorPad { return .init(cCells) }

    private init(_ sensorPadCCells: Int) {
        self.cCells = sensorPadCCells

        self.thePad = .allocate(capacity: sensorPadCCells)

        self.thePad.initialize(
            repeating: nil, count: sensorPadCCells
        )

        (0..<sensorPadCCells).forEach { self.thePad[$0] = IngridCellConnector() }
    }

    func localIndexToAbsolute(_ localIx: Int) -> Int { thePad[localIx]!.absoluteIndex }
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
    func disengageGrid(_ jumpTargetLocalIndex: Int, _ onComplete: @escaping () -> Void) {
        let jumpedTo = thePad[jumpTargetLocalIndex]!.absoluteIndex
        Ingrid.shared.unlockCells([jumpedTo])
    }

    func engageBirthCell(center absoluteIndex: Int, _ onComplete: @escaping () -> Void) {
        let mapper = SensorPadMapper(1, absoluteIndex, thePad, onComplete)
        Ingrid.shared.engageGrid(mapper)
    }

    func firstFullGridEngage(
        center absoluteIndex: Int, _ lockCompletionCallback: @escaping () -> Void
    ) {
        let alreadyLockedCell = thePad[0]

        let mapper = mapSensorPadToGrid(absoluteIndex, cCells, true, lockCompletionCallback)

        thePad[0] = alreadyLockedCell
        Ingrid.shared.engageGrid(mapper, centerCellIsAlreadyLocked: true)
    }

    func engageGrid(center absoluteIndex: Int, _ onComplete: @escaping () -> Void) {
        let mapper = mapSensorPadToGrid(absoluteIndex, cCells, false, onComplete)
        Ingrid.shared.engageGrid(mapper) // completion callback is inside the mapper
    }

    private func mapSensorPadToGrid(
        _ centerAbsoluteIndex: Int, _ cCells: Int,
        _ centerCellIsAlreadyLocked: Bool,
        _ lockCompletionCallback: @escaping () -> Void
    ) -> SensorPadMapper {

        let start = centerCellIsAlreadyLocked ? 1 : 0

        Debug.log(level: 200) { "mapSensorPadToGrid start at localIx \(start)" }

        for ss in start..<cCells {
            var p = Ingrid.shared.indexer.getGridPointByLocalIndex(
                center: centerAbsoluteIndex, targetIndex: ss
            )

            var vp: CGPoint?    // Virtual target for teleportation

            if let q = Ingrid.shared.core.correctForDisjunction(p)
                { vp = p.asPoint(); p = q }

            let cell = Ingrid.shared.cellAt(p)

            Debug.log(level: 200) { "requesting cell at \(cell.absoluteIndex) (local \(ss))" }
            thePad[ss] = IngridCellConnector(cell, vp)
        }

        return SensorPadMapper(
            cCells, centerAbsoluteIndex, thePad, lockCompletionCallback
        )
    }
}
