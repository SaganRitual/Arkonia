import Foundation

class IngridLock {
    var isLocked = false
    let waitingLockRequests = Cbuffer<SensorPadMapper>(cElements: 10, mode: .fifo)
}

class Ingrid {
    static var shared: Ingrid!

    let arkons: IngridArkons
    let core: IngridCore
    let indexer: IngridIndexer
    let locks: UnsafeMutableBufferPointer<IngridLock?>
    let manna: IngridManna
    let sprites: IngridSprites

    private let lockQueue = DispatchQueue(
        label: "ak.grid.serial", target: DispatchQueue.global()
    )

    init(
        cellDimensionsPix: CGSize, portalDimensionsPix: CGSize,
        maxCSenseRings: Int, funkyCellsMultiplier: CGFloat?
    ) {
        self.indexer = .init(maxCSenseRings: maxCSenseRings)

        core = .init(
            cellDimensionsPix: cellDimensionsPix,
            portalDimensionsPix: portalDimensionsPix,
            maxCSenseRings: maxCSenseRings,
            funkyCellsMultiplier: funkyCellsMultiplier
        )

        let cCells = core.gridDimensionsCells.area()

        arkons = IngridArkons(cCells)
        manna = IngridManna(cCells)
        sprites = IngridSprites(cCells)

        locks = .allocate(capacity: cCells)
        locks.initialize(repeating: nil)
        for ss in 0..<cCells { locks[ss] = IngridLock() }
    }

    func cellAt(_ absolutePosition: AKPoint) -> IngridCell { core.cellAt(absolutePosition) }
    func cellAt(_ absoluteIndex: Int) -> IngridCell { core.cellAt(absoluteIndex) }

    // It's ok for this to be called outside of the lock queue, because the
    // readyCellAbsoluteIndex comes from the arkon's sensor pad, which means
    // he has this cell locked already, and no one else will be looking at it
    func completeDeferredLockRequest(for readyCellAbsoluteIndex: Int) {
        let lock = locks[readyCellAbsoluteIndex]!

        if lock.waitingLockRequests.isEmpty {
            if Arkonia.debugGrid { sprites.showLock(readyCellAbsoluteIndex, .unlocked) }

            lock.isLocked = false
            return
        }

        let mapper = lock.waitingLockRequests.popFront()
        Debug.log(level: 198) { "completeDeferredLockRequest for \(readyCellAbsoluteIndex)" }
        if Arkonia.debugGrid { sprites.showLock(readyCellAbsoluteIndex, .deferredAndCompleted) }

        connectSensorPad(mapper)
        MainDispatchQueue.async(execute: mapper.onComplete)
    }

    private func connectSensorPad(_ mapper: SensorPadMapper) {
        // When we come here, we have the center cell locked, so
        // we start from 1 instead of 0
        for localIx in 1..<mapper.sensorPadCCells {
            let cellDescriptor = mapper.sensorPadThePad[localIx]!
            let lock = self.locks[cellDescriptor.absoluteIndex]!

            // The mapper has filled out its sensor pad optimistically,
            // assuming all the cells it requests can be locked. Here we
            // give it the bad news about any it's not allowed to have, by
            // replacing non-locked descriptors with blind ones
            if lock.isLocked {
                mapper.sensorPadThePad[localIx] = IngridCellConnector(
                    nil, cellDescriptor.absoluteIndex, nil
                )

                if Arkonia.debugGrid { sprites.showLock(cellDescriptor.absoluteIndex, .blind) }
            } else {
                Debug.log(level: 200) { "locking \(cellDescriptor.absoluteIndex) (local \(localIx))"}
                // Good news for the requester
                if Arkonia.debugGrid { sprites.showLock(cellDescriptor.absoluteIndex, .locked) }
                self.locks[cellDescriptor.absoluteIndex]!.isLocked = true
            }
        }
    }

    func deferLockRequest(
        _ mapper: SensorPadMapper,
        _ onDefermentComplete: @escaping (SensorPadMapper) -> Void
    ) {
        if Arkonia.debugGrid { sprites.showLock(mapper.centerAbsoluteIndex, .deferred) }
        let deferer = SensorPadMapper(mapper, onDefermentComplete)
        locks[mapper.centerAbsoluteIndex]!.waitingLockRequests.pushBack(deferer)
    }

    func engageGrid(
        _ mapper: SensorPadMapper, centerCellIsAlreadyLocked: Bool = false
    ) {
        lockQueue.async { self.engageGrid_A(mapper, centerCellIsAlreadyLocked) }
    }

    private func engageGrid_A(
        _ mapper: SensorPadMapper, _ centerCellIsAlreadyLocked: Bool
    ) {
        let centerLock = self.locks[mapper.centerAbsoluteIndex]!
        let p = Ingrid.absolutePosition(of: mapper.centerAbsoluteIndex)
        Debug.log(level: 204) { "engageGrid_A \(mapper.centerAbsoluteIndex) \(p)" }

        if centerLock.isLocked && !centerCellIsAlreadyLocked {
            self.deferLockRequest(mapper, connectSensorPad)
            return
        }

        // Lock the cell and get off the lock queue
        let centerCell = cellAt(mapper.centerAbsoluteIndex)

        centerLock.isLocked = true
        mapper.sensorPadThePad[0] = IngridCellConnector(centerCell)
        if Arkonia.debugGrid { sprites.showLock(mapper.centerAbsoluteIndex, .centerLock) }

        connectSensorPad(mapper)
        MainDispatchQueue.async(execute: mapper.onComplete)
    }

    func moveArkon(
        _ stepper: Stepper, fromCell: IngridCell, toCell: IngridCell
    ) {
        arkons.moveArkon(fromCell: fromCell, toCell: toCell)
        completeDeferredLockRequest(for: fromCell.absoluteIndex)
    }

    func placeArkonOnGrid(_ stepper: Stepper, atIndex: Int) {
        arkons.placeArkonOnGrid(stepper, atIndex: atIndex)
    }

    func releaseArkon(_ stepper: Stepper) {
        lockQueue.async {
            let releasedCellIx = self.arkons.releaseArkon(stepper)
            self.completeDeferredLockRequest(for: releasedCellIx)
        }
    }

    func unlockCells(_ absoluteIndexes: [Int]) {
        absoluteIndexes.forEach { completeDeferredLockRequest(for: $0) }
    }
}

extension Ingrid {
    enum CellContents: Float {
        case invisible = 0, arkon = 1, empty = 2, manna = 3

        func asSenseData() -> Float { return self.rawValue / 4.0 }
    }

    func getContents(in absoluteIndex: Int) -> CellContents {
        if Ingrid.shared.arkons.arkonAt(absoluteIndex) != nil { return .arkon }
        else if Ingrid.shared.manna.mannaAt(absoluteIndex) != nil { return .manna }

        return .empty
    }

    func getContents(in cell: IngridCell) -> CellContents {
        return getContents(in: cell.absoluteIndex)
    }
}

extension Ingrid {
    static func absoluteIndex(of point: AKPoint) -> Int {
        Ingrid.shared.core.absoluteIndex(of: point)
    }

    static func absolutePosition(of index: Int) -> AKPoint {
        Ingrid.shared.core.absolutePosition(of: index)
    }

    static func randomCell() -> IngridCellConnector {
        return IngridCellConnector(Ingrid.shared.cellAt(randomCellIndex()))
    }

    static func randomCell() -> IngridCell {
        return Ingrid.shared.cellAt(randomCellIndex())
    }

    static func randomCellIndex() -> Int {
        let cCellsInGrid = Ingrid.shared.core.gridDimensionsCells.area()
        return Int.random(in: 0..<cCellsInGrid)
    }
}
