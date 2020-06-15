import Foundation

class IngridLock {
    var isLocked = false
    let waitingLockRequests = Cbuffer<EngagerSpec>(cElements: 10, mode: .fifo)
}

class Ingrid {
    static var shared: Ingrid!

    private let arkons: IngridArkons
    private let core: IngridCore
    private let locks: UnsafeMutableBufferPointer<IngridLock?>
    private let manna: IngridManna

    private let lockQueue = DispatchQueue(
        label: "ak.grid.serial", target: DispatchQueue.global()
    )

    init(
        cellDimensionsPix: CGSize, portalDimensionsPix: CGSize,
        maxCSenseRings: Int, funkyCellsMultiplier: CGFloat?
    ) {
        core = IngridCore(
            cellDimensionsPix: cellDimensionsPix,
            portalDimensionsPix: portalDimensionsPix,
            maxCSenseRings: maxCSenseRings,
            funkyCellsMultiplier: funkyCellsMultiplier
        )

        let cCells = core.gridDimensionsCells.area()

        arkons = IngridArkons(cCells)
        manna = IngridManna(cCells)

        locks = .allocate(capacity: cCells)
        locks.initialize(repeating: nil)
        for ss in 0..<cCells { locks[ss] = IngridLock() }
    }

    func cellAt(_ absolutePosition: AKPoint) -> IngridCell { core.cellAt(absolutePosition) }
    func cellAt(_ absoluteIndex: Int) -> IngridCell { core.cellAt(absoluteIndex) }

    func completeDeferredLockRequest(for readyCellAbsoluteIndex: Int) {
        let lock = lockAt(readyCellAbsoluteIndex)

        if lock.waitingLockRequests.isEmpty { lock.isLocked = false; return }

        let engagerSpec = lock.waitingLockRequests.popFront()
        Debug.log(level: 198) { "completeDeferredLockRequest for \(readyCellAbsoluteIndex)" }

        core.engageSensorPad(engagerSpec)
        Dispatch.dispatchQueue.async(execute: engagerSpec.onComplete)
    }

    func deferLockRequest(_ engagerSpec: EngagerSpec, _ onDefermentComplete: @escaping (EngagerSpec) -> Void) {
        Debug.log(level: 198) { "deferLockRequest for \(engagerSpec.centerAbsoluteIndex)" }
        let lock = lockAt(engagerSpec.centerAbsoluteIndex)
        hardAssert(lock.isLocked) { "Deferred but the cell isn't locked" }
        lock.waitingLockRequests.pushBack(engagerSpec)
    }

    func disengageSensorPad(
        _ pad: UnsafeMutablePointer<IngridCellDescriptor>,
        padCCells: Int,
        keepTheseCellsByLocalIndex: [Int],
        _ onComplete: @escaping () -> Void
    ) {
        let aix: (Int) -> Int = { pad[$0].absoluteIndex }

        let cog = (0..<padCCells).filter({ pad[$0].coreCell != nil && !keepTheseCellsByLocalIndex.contains($0) }).map { "\(aix($0))" }
        Debug.log(level: 198) { "disengageSensorPad \(cog)" }
        lockQueue.async {
            for localPadIx in (0..<padCCells) where pad[localPadIx].coreCell != nil && !keepTheseCellsByLocalIndex.contains(localPadIx) {
                // Invalidate the caller's pad so he won't think he can just
                // come back and mess about the place
                pad[localPadIx] = IngridCellDescriptor(nil, aix(localPadIx), nil)

                if self.locks[aix(localPadIx)]!.isReadyForDeferCompletion {
                    self.locks[aix(localPadIx)]!.isReadyForDeferCompletion = false
                    self.completeDeferredLockRequest(for: localPadIx)
                }
            }

            self.nonCriticalsQueue.async(execute: onComplete)
        }
    }

    func engageSensorPad(_ engagerSpec: EngagerSpec) {
        lockQueue.async { self.engageSensorPad_A(engagerSpec) }
    }

    private func engageSensorPad_A(_ engagerSpec: EngagerSpec) {
        let centerLock = self.locks[engagerSpec.centerAbsoluteIndex]!

        if centerLock.isLocked {
            self.deferLockRequest(engagerSpec, engageSensorPad_B)
            return
        }

        engageSensorPad_B(engagerSpec)
    }

    private func engageSensorPad_B(_ engagerSpec: EngagerSpec) {
        self.core.engageSensorPad(engagerSpec)

        for localIx in 1..<engagerSpec.sensorPadCCells {
            let cellDescriptor = engagerSpec.sensorPad[localIx]
            let lock = self.locks[cellDescriptor.absoluteIndex]!

            // The core doesn't know about locks, so it gives us back raw
            // cell descriptors that can access even cells that are already
            // locked (by someone else). Here we check for those cells and
            // block the sensor pad from seeing them by replacing the descriptor
            // with a blind one
            if lock.isLocked {
                engagerSpec.sensorPad[localIx] = IngridCellDescriptor(
                    nil, cellDescriptor.absoluteIndex, nil
                )

                continue
            }

            self.locks[cellDescriptor.absoluteIndex]!.isLocked = true
        }

        let cog = (0..<engagerSpec.sensorPadCCells).map { engagerSpec.sensorPad[$0] }
        Debug.log(level: 198) { "Ingrid.engageSensorPad: \(cog)" }
        self.nonCriticalsQueue.async(execute: engagerSpec.onComplete)
    }

    func lockAt(_ absolutePosition: AKPoint) -> IngridLock {
        let ax = Ingrid.absoluteIndex(of: absolutePosition)
        return locks[ax]!
    }

    func lockAt(_ absoluteIndex: Int) -> IngridLock { return locks[absoluteIndex]! }

    func moveArkon(_ stepper: Stepper, fromCell: IngridCell, toCell: IngridCell) {
        arkons.moveArkon(foo: stepper, fromCell: fromCell, toCell: toCell)

        // When the arkon disengages his sensor pad from the grid, this
        // will cause it to check whether anyone is waiting on the lock
        // for this cell
        locks[fromCell.absoluteIndex]!.isReadyForDeferCompletion = true
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

    static func randomCell() -> IngridCell {
        return Ingrid.shared.cellAt(randomCellIndex())
    }

    static func randomCellIndex() -> Int {
        let cCellsInGrid = Ingrid.shared.core.gridDimensionsCells.area()
        return Int.random(in: 0..<cCellsInGrid)
    }
}
