import Foundation

class SensorPad {
    static var gridSync: GridSync?

    var jumpedFromGridAbsoluteIndex: Int?
    var thePadCells = [SensorPadCell]()

    var centerAbsoluteIndex: Int? { thePadCells[0].liveGridCell?.properties.gridAbsoluteIndex }

    var centerCellScenePosition: CGPoint? {
        thePadCells[0].liveGridCell?.properties.scenePosition
    }

    var centerAbsoluteGridPosition: AKPoint? {
        centerAbsoluteIndex == nil ? nil : Grid.gridPosition(of: centerAbsoluteIndex!)
    }

    var gridSync: GridSync { SensorPad.gridSync! }

    init(_ cCells: Int, _ birthCell: GridCell) {
        thePadCells.reserveCapacity(cCells)

        (0..<cCells).forEach { thePadCells.append(.init($0)) }

        // This is where we'll begin life, either in the cell proper, or
        // on its deferred requests list
        thePadCells[0].mapToGrid(centerOfPad: birthCell.properties.gridAbsoluteIndex)

        mapToGrid(startAt: 1)
    }

    func disengageSensorPad(_ onComplete: @escaping () -> Void) {
        var toRelease = [centerAbsoluteIndex!]

        if let jumpedFrom = self.jumpedFromGridAbsoluteIndex { toRelease.append(jumpedFrom) }

        let name = (Grid.cellAt(self.centerAbsoluteIndex!).contents.arkon as? Stepper)!.name
        Debug.log(level: 209) { "disengageSensorPad \(name); release locks \(toRelease)" }

        gridSync.releaseLocks(toRelease, onComplete)
    }

    func disengagePadCells(_ cellAbsoluteIndices: [Int], _ onComplete: @escaping () -> Void) {
        if cellAbsoluteIndices.isEmpty { onComplete(); return }

        let name = (Grid.cellAt(self.centerAbsoluteIndex!).contents.arkon as? Stepper)!.name
        Debug.log(level: 209) { "disengagePadCells \(name); release locks \(cellAbsoluteIndices)" }
        gridSync.releaseLocks(cellAbsoluteIndices, onComplete)
    }

    func engageSensorPad(for arkon: Stepper, _ onComplete: @escaping () -> Void) {
        gridSync.engageSensorPad(for: arkon, onComplete)
    }

    func mapToGrid(startAt: Int) {
        for localIndex in startAt..<thePadCells.count {
            thePadCells[localIndex].mapToGrid(centerOfPad: centerAbsoluteIndex!)
        }
    }
}

extension SensorPad {
    func getNutrition(at localIndex: Int) -> Float {
        let absoluteIndex = thePadCells[localIndex].liveGridCell!.properties.gridAbsoluteIndex

        if let arkon = Grid.arkonAt(absoluteIndex) {
            return Float(arkon.metabolism.energy.level)
        }

        if let manna = Grid.mannaAt(absoluteIndex) {
            return Float(manna.sprite.getMaturityLevel())
        }

        return 0
    }

    func loadSelector(at localIndex: Int) -> Float {
        thePadCells[localIndex].liveGridCell!.contents.contents.asSenseData()
    }
}

extension SensorPad {
    private func invalidateToShuttle(_ keepLocalIndex: Int) -> [Int] {
        return (1..<thePadCells.count).compactMap {
            ($0 == keepLocalIndex) ? nil : thePadCells[$0].invalidate()
        }
    }

    // Release all the cells in the sensor pad that won't be involved in the
    // jump. The "shuttle" refers to the two cells remaining, which will always
    // be the center, at [0], and some other locked cell in the pad
    func pruneToShuttle(_ keepLocalIndex: Int, _ onComplete: @escaping () -> Void) {
        let absoluteIndexesToRelease = invalidateToShuttle(keepLocalIndex)
        // It's not unusual to get a sensor pad with only one possible jump target,
        // in which case the shuttle is all we have, so there's nothing to prune
        if absoluteIndexesToRelease.isEmpty { onComplete(); return }
        disengagePadCells(absoluteIndexesToRelease, onComplete)
    }
}

extension SensorPad {
    func getFirstTargetableCell(startingAt targetLocalIndex: Int) -> SensorPadCell? {
        var debugLogString = "["
        defer {
            debugLogString += "]"
            Debug.log(level: 209) { "\((Grid.cellAt(centerAbsoluteIndex!).contents.arkon! as? Stepper)!.name) " + debugLogString }
        }
        var separator = ""
        for ss_ in 0..<thePadCells.count {
            defer { separator = ", " }
            debugLogString += separator

            let localIndex = (ss_ + targetLocalIndex) % thePadCells.count
            debugLogString += "\(localIndex)"

            // If the target cell isn't available (meaning we couldn't
            // see it when we tried to lock it, because someone had that
            // cell locked already), then find the first visible cell after
            // our target. If that turns out to be the cell I'm checking,
            // skip it and look for the next after that. I've decided to
            // jump already, so, I'll jump.
            //
            // No particular reason for this policy. We could just as easily
            // stay here. Maybe put it under genetic control and see if it
            // has any effect
            if localIndex == 0 { debugLogString += " -> center"; continue }

            // If we don't get a core cell, it's because we don't have the
            // cell locked (someone else has it), so we can't jump there
            if !thePadCells[localIndex].iHaveTheLock { debugLogString += " -> blind"; continue }

            let contents = thePadCells[localIndex].liveGridCell!.contents

            // Of course, don't forget that we can't squeeze into the
            // same cell as another arkon, at least not for now
            if contents.hasArkon() { debugLogString += " -> \((contents.arkon! as? Stepper)!.name)"; continue }

            debugLogString += " -> \(localIndex)"
            return thePadCells[localIndex]
        }

        debugLogString += "--- nothing found!"
        return nil
    }
}

extension SensorPad {
    func moveArkon(to targetCell: SensorPadCell) {
        self.jumpedFromGridAbsoluteIndex = thePadCells[0].gridAbsoluteIndex
        Grid.moveArkon(from: centerAbsoluteIndex!, toGridCell: targetCell.liveGridCell!)
        self.movePad(to: targetCell)
        gridSync.completeDeferredLockRequest(centerAbsoluteIndex!)
    }

    private func movePad(to targetCell: SensorPadCell) {
        thePadCells[0].iHaveTheLock = true
        thePadCells[0].liveGridCell = targetCell.liveGridCell
        thePadCells[0].virtualGridPosition = targetCell.virtualGridPosition

        targetCell.iHaveTheLock = false
        targetCell.liveGridCell = nil
        targetCell.virtualGridPosition = nil

        mapToGrid(startAt: 1)
    }
}
