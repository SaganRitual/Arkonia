import Foundation

class SensorPad {
    let cCells: Int
    let thePad: UnsafeMutablePointer<IngridCellDescriptor>

    var jumpTargetLocalIndex: Int?

    static func makeSensorPad(_ cCells: Int) -> SensorPad { return .init(cCells) }

    private init(_ sensorPadCCells: Int) {
        self.cCells = sensorPadCCells

        self.thePad = .allocate(capacity: sensorPadCCells)

        self.thePad.initialize(
            repeating: IngridCellDescriptor(), count: sensorPadCCells
        )
    }

    func localIndexToAbsolute(_ localIx: Int) -> Int { thePad[localIx].absoluteIndex }
}

extension SensorPad {
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

        // After we jump, we'll need to remember this so we can free
        // it back to the grid when we disengage
        jumpTargetLocalIndex = absoluteIndexesToUnlock[1]

        Ingrid.shared.unlockCells(absoluteIndexesToUnlock)
    }
}

extension SensorPad {
    func disengageGrid(_ onComplete: @escaping () -> Void) {
        let jumpedTo = thePad[jumpTargetLocalIndex!].absoluteIndex
        Ingrid.shared.unlockCells([jumpedTo])
    }

    func engageBirthCell(center absoluteIndex: Int, _ onComplete: @escaping () -> Void) {
        let mapper = SensorPadMapper(1, absoluteIndex, thePad, onComplete)
        Ingrid.shared.engageGrid(mapper)
    }

    func firstFullGridEngage(center absoluteIndex: Int, _ onComplete: @escaping () -> Void) {
        let mapper = SensorPadMapper(cCells, absoluteIndex, thePad, onComplete)
        Ingrid.shared.engageGrid(mapper, centerCellIsAlreadyLocked: true)
    }

    func engageGrid(center absoluteIndex: Int, _ onComplete: @escaping () -> Void) {
        let mapper = mapSensorPadToGrid(absoluteIndex, cCells, onComplete)
        Ingrid.shared.engageGrid(mapper) // completion callback is inside the mapper
    }

    private func mapSensorPadToGrid(
        _ centerAbsoluteIndex: Int, _ cCells: Int, _ onComplete: @escaping () -> Void
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

    func reset() {  }
}

extension SensorPad {

    struct CorrectedTarget {
        let toCell: IngridCell
        let finalTargetLocalIx: Int
        let virtualScenePosition: CGPoint?
    }

    func getCorrectedTarget(candidateLocalIndex targetOffset: Int) -> CorrectedTarget? {
        var toCell: IngridCell?
        var finalTargetLocalIx: Int?
        var virtualScenePosition: CGPoint?

        Debug.log(level: 198) { "getCorrectedTarget.0 try \(targetOffset)" }

        for ss_ in 0..<cCells where toCell == nil {
            let ss = (ss_ + targetOffset) % cCells

            // If the target cell isn't available (meaning we couldn't
            // see it when we tried to lock it, because someone had that
            // cell locked already), then find the first visible cell after
            // our target. If that turns out to be the cell I'm sitting in,
            // skip it and look for the next after that. I've decided to
            // jump already, so, I'll jump.
            //
            // No particular reason for this policy. We could just as easily
            // stay here. Maybe put it under genetic control and see if it
            // has any effect
            if ss == cCells - 1 {
                Debug.log(level: 198) { "getCorrectedTarget.1 skipping pad[0] at \(ss)" }
                continue
            }

            // If we don't get a core cell, it's because we don't have the
            // cell locked (someone else has it), so we can't jump there
            guard let coreCell = thePad[ss].coreCell else {
                Debug.log(level: 198) { "getCorrectedTarget.2 no lock at \(ss)" }
                continue
            }

            // Of course, don't forget that we can't squeeze into the
            // same cell as another arkon, at least not for now
            let contents = Ingrid.shared.getContents(in: coreCell)
            if contents == .empty || contents == .manna {
                finalTargetLocalIx = ss
                toCell = coreCell
                virtualScenePosition = thePad[ss].virtualScenePosition
                break
            }
        }

        guard let t = toCell else { return nil }

        return CorrectedTarget(
            toCell: t, finalTargetLocalIx: finalTargetLocalIx!,
            virtualScenePosition: virtualScenePosition
        )
    }

}
