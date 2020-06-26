class Spindle {
    enum State {
        case inBirthCellWithLockFromParent
        case inBirthLimboAwaitingTargetCellReady
        case normal
    }

    weak var arkon: Stepper!
    weak var gridCell: GridCell!
    weak var sensorPad: SensorPad!
    var state: State

    init(at gridCell: GridCell, initialState: State) {
        self.gridCell = gridCell
        self.state = initialState
    }

    func postInit(_ arkon: Stepper) {
        self.arkon = arkon; self.sensorPad = arkon.sensorPad
    }
}

extension Spindle {
    private func attachToCell(iHaveTheLiveConnection: Bool, _ onComplete: @escaping () -> Void) {
        state = .normal
        occupyCell(self.gridCell, iHaveTheLiveConnection: iHaveTheLiveConnection)
        MainDispatchQueue.async(execute: onComplete)
    }

    func attachToGrid(iHaveTheLiveConnection: Bool, _ onComplete: @escaping () -> Void) {
        switch state {
        case .inBirthCellWithLockFromParent:
            attachToCell(iHaveTheLiveConnection: iHaveTheLiveConnection, onComplete)

        case .inBirthLimboAwaitingTargetCellReady:
            GridLock.lockQueue.async {
                self.lockSpindleTarget(self.gridCell, gridIsLocked: true, onComplete)
            }

        default: fatalError("This is only for birth-related attachments")
        }
    }

    func getLifecycleLock(_ onComplete: @escaping () -> Void) {
        state = .normal
        GridLock.lockQueue.async { self.lockCurrentCell(gridIsLocked: true, onComplete) }
    }
}

private extension Spindle {
    func lockCurrentCell(gridIsLocked: Bool, _ onLocked: @escaping () -> Void) {
        assert(gridIsLocked)

        if self.gridCell.lock.isLocked {
            Debug.log(level: 214) { "lockCurrentCell.defer \(gridCell.properties)" }
            self.deferredLock(self.gridCell, gridIsLocked: gridIsLocked, onLocked)
        } else {
            Debug.log(level: 214) { "lockCurrentCell.immediateLock \(gridCell.properties)" }
            self.immediateLock(self.gridCell, gridIsLocked: gridIsLocked, onLocked)
        }
    }

    func lockSpindleTarget(
        _ cell: GridCell, gridIsLocked: Bool, _ onAttached: @escaping () -> Void
    ) {
        assert(gridIsLocked)
        Debug.log(level: 214) { "lockSpindleTarget \(gridCell.properties)" }

        // Do we really have the live connection here?
        func onLocked() { attachToCell(iHaveTheLiveConnection: true, onAttached) }

        switch (cell.contents.hasArkon(), cell.lock.isLocked) {
        case (true,  _):     fallthrough
        case (false, true):  self.deferredLock(cell, gridIsLocked: gridIsLocked, onLocked)
        case (false, false): self.immediateLock(cell, gridIsLocked: gridIsLocked, onLocked)
        }
    }

    func deferredLock(_ cell: GridCell, gridIsLocked: Bool, _ onCellIsLocked: @escaping () -> Void) {
        assert(gridIsLocked)
        Debug.log(level: 214) { "Spindle.deferredLock at \(gridCell.properties)" }
        hardAssert(
            state == .normal || state == .inBirthLimboAwaitingTargetCellReady
        ) { "Invalid state for deferral \(self.state)" }

        let normalLock = state == .normal
        cell.lock.deferRequest(for: cell, normalLock: normalLock, gridIsLocked: gridIsLocked, onCellIsLocked)
    }

    func immediateLock(
        _ cell: GridCell, gridIsLocked: Bool, _ onCenterIsLocked: @escaping () -> Void
    ) {
        assert(gridIsLocked)

        Debug.log(level: 215) { "Spindle.immediateLock \(AKName(arkon.name)) for \(gridCell.properties)" }

        state = .normal
        cell.lock.isLocked = true
        MainDispatchQueue.async(execute: onCenterIsLocked)
    }
}

extension Spindle {

    func move(to newCell: GridCell, iHaveTheLiveConnection: Bool) {
        assert(iHaveTheLiveConnection)
        vacateCurrentCell(iHaveTheLiveConnection: iHaveTheLiveConnection)
        occupyCell(newCell, iHaveTheLiveConnection: iHaveTheLiveConnection)
    }

    func occupyCell(_ cell: GridCell, iHaveTheLiveConnection: Bool) {
        assert(iHaveTheLiveConnection)
        self.gridCell = cell
        cell.contents.arkon = self
    }

    func vacateCurrentCell(iHaveTheLiveConnection: Bool) {
        assert(iHaveTheLiveConnection)
        gridCell.contents.arkon = nil
        gridCell = nil
    }

}
