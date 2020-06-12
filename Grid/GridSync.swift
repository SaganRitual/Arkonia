import Foundation

struct GridLockRequest {
    let arkon: Stepper
    let onComplete: () -> Void

    init(
        _ arkon: Stepper, _ onComplete: @escaping () -> Void
    ) {
        self.arkon = arkon
        self.onComplete = onComplete
    }
}

class GridLock {
    var isLocked = false
    let deferredLockRequests = Cbuffer<GridLockRequest>(cElements: 10, mode: .fifo)
}

struct GridSync {
    private let lockQueue = DispatchQueue(
        label: "ak.grid.serial", target: DispatchQueue.global()
    )
}

extension GridSync {
    func lockRandomCell(_ onComplete: @escaping (GridCell) -> Void) {
        let cell = Grid.randomCell()

        func lockRandomCell_A() { lockQueue.async(execute: lockRandomCell_B) }

        func lockRandomCell_B() {
            if cell.lock.isLocked { lockRandomCell_C() } else { lockRandomCell_D() }
        }

        func lockRandomCell_C() {
            MainDispatchQueue.asyncAfter(deadline: .now() + 0.25) { self.lockRandomCell(onComplete) }
        }

        func lockRandomCell_D() {
            cell.lock.isLocked = true
            MainDispatchQueue.async { onComplete(cell) }
        }

        lockRandomCell_A()
    }
}

extension GridSync {
    func attachArkonToGrid(
        _ newborn: Stepper, _ onComplete: @escaping () -> Void
    ) {
        Grid.placeNewborn(newborn, at: newborn.sensorPad.centerAbsoluteIndex!)

        let lockRequest = GridLockRequest(newborn, onComplete)
        engageSensorPad_C_engagePositiveCells(lockRequest)
    }
}

extension GridSync {
    // Note that it's ok to call this function without having the whole grid
    // locked, because the cells we're addressing are coming from some arkon's
    // sensor pad, meaning the arkon is guaranteed to be the only one looking
    // at these particular cells
    func completeDeferredLockRequest(_ absoluteIndex: Int) {
        Debug.log(level: 208) { "completeDeferredLockRequest(\(absoluteIndex)).0" }
        let lock = Grid.cellAt(absoluteIndex).lock

        if lock.deferredLockRequests.isEmpty {
            Debug.log(level: 208) { "completeDeferredLockRequest(\(absoluteIndex)).1" }
            lock.isLocked = false
            return
        }

        Debug.log(level: 209) { "completeDeferredLockRequest(\(absoluteIndex)).2" }
        let request = lock.deferredLockRequests.popFront()
        engageSensorPad_C_engagePositiveCells(request)
    }

    func deferLockRequest(_ lockRequest: GridLockRequest) {
        Debug.log(level: 209) { "deferLockRequest(absix \(lockRequest.arkon.sensorPad.centerAbsoluteIndex!), \(lockRequest.arkon.name)).0" }
        let ix = lockRequest.arkon.sensorPad.centerAbsoluteIndex!
        let theLock = Grid.cellAt(ix).lock
        theLock.deferredLockRequests.pushBack(lockRequest)
    }

    func gridCellIsLocked(_ absoluteIndex: Int) -> Bool
        { Grid.cellAt(absoluteIndex).lock.isLocked }
}

extension GridSync {
    func releaseLocks(_ absoluteIndexes: [Int], _ onComplete: @escaping () -> Void) {
        absoluteIndexes.forEach(completeDeferredLockRequest)
        onComplete()
    }
}

extension GridSync {
    func engageSensorPad(
        for arkon: Stepper, _ onComplete: @escaping () -> Void
    ) {
        lockQueue.async {
            self.engageSensorPad_B_engageCenter(arkon, onComplete)
        }
    }

    func engageSensorPad_B_engageCenter(
        _ arkon: Stepper, _ onComplete: @escaping () -> Void
    ) {
        let centerSensorPadCell = arkon.sensorPad.thePadCells[0]
        let centerAbsoluteIndex = centerSensorPadCell.gridAbsoluteIndex!

        let lockRequest = GridLockRequest(arkon, onComplete)

        Debug.log(level: 209) { "engageSensorPad_B \(arkon.name) engageCenter(\(centerAbsoluteIndex)).0" }

        if Grid.cellAt(centerAbsoluteIndex).lock.isLocked {
            deferLockRequest(lockRequest)
            return
        }

        self.engageSensorPad_C_engagePositiveCells(lockRequest)
    }

    // "positive cells" being those with a local index > 0, because index == 0
    // is the center, and we have that locked already
    func engageSensorPad_C_engagePositiveCells(_ lockRequest: GridLockRequest) {
        lockQueue.async {
            self.engageSensorPad_D_lockCells(lockRequest)
        }
    }

    func engageSensorPad_D_lockCells(_ lockRequest: GridLockRequest) {
        var debugString = "lock cells for \(lockRequest.arkon.name): ["
        var separator = ""

        lockRequest.arkon.sensorPad.thePadCells.forEach {
            defer { separator = "; " }

            let gridCell = $0.liveGridCell!

            debugString += separator +
                "\(gridCell.properties.gridAbsoluteIndex)"
                + (gridCell.lock.isLocked ? "(locked)" : "(available)")

            debugString += " -> localCellIx \($0.padLocalIndex) "

            if gridCell.lock.isLocked {
                debugString += " blind"
            } else {
                $0.iHaveTheLock = true
                gridCell.lock.isLocked = true
                debugString += " contents \(gridCell.contents.contents)"
            }
        }

        Debug.log(level: 209) { "\(debugString)]" }
        lockRequest.onComplete()
    }
}
