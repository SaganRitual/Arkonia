import Foundation

class SensorPad {
    let cCells: Int
    let thePad: UnsafeMutablePointer<IngridCellDescriptor>

    func localIndexToAbsolute(_ localIx: Int) -> Int { thePad[localIx].absoluteIndex }

    static func makeLandingPad() -> SensorPad { return .init(1) }
    static func makeSensorPad(_ cCells: Int) -> SensorPad { return .init(cCells) }

    private init(_ sensorPadCCells: Int) {
        self.cCells = sensorPadCCells

        self.thePad = .allocate(capacity: sensorPadCCells)

        self.thePad.initialize(
            repeating: IngridCellDescriptor(), count: sensorPadCCells
        )
    }
}

extension SensorPad {
    func detachLandingPad() -> IngridCellDescriptor {
        defer { thePad.deallocate() }
        return IngridCellDescriptor(thePad[0].coreCell!)
    }

    // Release all the cells in the sensor pad that won't be involved in the
    // jump. The "shuttle" refers to the two cells remaining, which will always
    // be the center, at [0], and some other locked cell in the pad
    func pruneToShuttle(_ keepLocalIndex: Int) {
        let absoluteIndexesToUnlock: [Int] = (1..<cCells).compactMap { localPadIx in
            // If this cell in the sensor pad isn't hot, then we don't
            // need to do anything to it
            if thePad[localPadIx].coreCell == nil { return nil }

            let absoluteCellIx = localIndexToAbsolute(localPadIx)

            // Invalidate the caller's pad so he won't think he can just
            // come back and mess about the place
            thePad[localPadIx] = IngridCellDescriptor(absoluteCellIx)

            return absoluteCellIx
        }

        Ingrid.shared.unlockCells(absoluteIndexesToUnlock)
    }
}

extension SensorPad {
    func engageGrid(_ onComplete: @escaping () -> Void) {
        let centerAbsoluteIndex = localIndexToAbsolute(0)
        let mapper = mapSensorPadToGrid(centerAbsoluteIndex, onComplete)
        Ingrid.shared.lockCells(mapper) // completion callback is inside the mapper
    }

    private func mapSensorPadToGrid(
        _ centerAbsoluteIndex: Int, _ onComplete: @escaping () -> Void
    ) -> SensorPadMapper {
        for ss in 0..<cCells {
            var p = Ingrid.shared.indexer.getGridPointByLocalIndex(
                center: centerAbsoluteIndex, targetIndex: ss
            )

            var vp: CGPoint?    // Virtual target for teleportation

            if let q = Ingrid.shared.core.correctForDisjunction(p)
                { vp = p.asPoint(); p = q }

            let cell = Ingrid.shared.cellAt(p)

            thePad[ss] = IngridCellDescriptor(cell, vp)
        }

        return SensorPadMapper(
            cCells, centerAbsoluteIndex, thePad, onComplete
        )
    }

    func reset() { }
}
