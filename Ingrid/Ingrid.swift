import Foundation

class IngridLock {
    var isLocked = false
    let waitingLockRequests = Cbuffer<EngagerSpec>(cElements: 10, mode: .fifo)
}

class Ingrid {
    static var shared: Ingrid!

    let arkons: IngridArkons
    let core: IngridCore
    let locks: UnsafeMutableBufferPointer<IngridLock?>
    let manna: IngridManna

    let lockQueue = DispatchQueue(
        label: "ak.grid.serial", target: DispatchQueue.global()
    )

    let nonCriticalsQueue = DispatchQueue(
        label: "ak.grid.concurrent", attributes: .concurrent, target: DispatchQueue.global()
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

    func completeDeferredLockRequest(for readyCell: Int) {
        let lock = lockAt(readyCell)

        if lock.waitingLockRequests.isEmpty { lock.isLocked = false; return }

        let engagerSpec = lock.waitingLockRequests.popFront()

        core.engageSensorPad(engagerSpec)
        engagerSpec.onComplete()
    }

    func deferLockRequest(_ engagerSpec: EngagerSpec) {
        let lock = lockAt(engagerSpec.center)
        lock.waitingLockRequests.pushBack(engagerSpec)
    }

    func disengageSensorPad(
        _ pad: UnsafeMutablePointer<IngridCellDescriptor>,
        padCCells: Int,
        keepTheseCells: [Int],
        _ onComplete: @escaping () -> Void
    ) {
        lockQueue.async {
            let aix: (Int) -> Int = { pad[$0].absoluteIndex }

            for padSS in (0..<padCCells) where pad[padSS].cell != nil && !keepTheseCells.contains(aix(padSS)) {
                self.completeDeferredLockRequest(for: aix(padSS))
            }

            self.nonCriticalsQueue.async(execute: onComplete)
        }
    }

    func engageSensorPad(_ engagerSpec: EngagerSpec) {
        lockQueue.async {
            let centerLock = self.locks[engagerSpec.center]!

            if centerLock.isLocked { self.deferLockRequest(engagerSpec); return }

            self.core.engageSensorPad(engagerSpec)

            for localIx in 0..<engagerSpec.cCellsInRange {
                let cellDescriptor = engagerSpec.pad[localIx]
                let lock = self.locks[cellDescriptor.absoluteIndex]!

                // The core doesn't know about locks, so it gives us back raw
                // cell descriptors that can access even cells that are already
                // locked (by someone else). Here we check for those cells and
                // block the sensor pad from seeing them by replacing the descriptor
                // with a blind one
                if lock.isLocked {
                    engagerSpec.pad[localIx] = IngridCellDescriptor(
                        nil, cellDescriptor.absoluteIndex, nil
                    )

                    continue
                }

                self.locks[cellDescriptor.absoluteIndex]!.isLocked = true
            }

            self.nonCriticalsQueue.async(execute: engagerSpec.onComplete)
        }
    }

    func lockAt(_ absolutePosition: AKPoint) -> IngridLock {
        let ax = Ingrid.absoluteIndex(of: absolutePosition)
        return locks[ax]!
    }

    func lockAt(_ absoluteIndex: Int) -> IngridLock { return locks[absoluteIndex]! }
}

extension Ingrid {
    enum CellContents: Float {
        case invisible = 0, arkon = 1, empty = 2, manna = 3

        func asSenseData() -> Float { return self.rawValue / 4.0 }
    }

    func getContents(in absoluteIndex: Int) -> CellContents {
        if Ingrid.shared.arkons.arkonAt(absoluteIndex) != nil { return .arkon }
        else if Ingrid.shared.manna.mannaAt(absoluteIndex) != nil { return .manna }

        return .invisible
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
