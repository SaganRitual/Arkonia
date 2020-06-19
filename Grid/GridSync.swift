import Foundation

typealias UnsafeGridLocks = UnsafeMutableBufferPointer<GridLock?>

class GridLock {
    var isLocked = false
    let deferredLockRequests = Cbuffer<GridLockRequest>(cElements: 10, mode: .fifo)
}

class GridSync {
    let locks: UnsafeGridLocks

    private let lockQueue = DispatchQueue(
        label: "ak.grid.serial", target: DispatchQueue.global()
    )

    init(_ cCells: Int) {
        locks = .allocate(capacity: cCells)
        locks.initialize(repeating: nil)
        for ss in 0..<cCells { locks[ss] = GridLock() }
    }

    func engageGrid(_ request: GridLockRequest) {
        lockQueue.async { self.engageGrid_B_requestLock(request) }
    }
}

private extension GridSync {
    func completeDeferredLockRequest(_ absoluteIndex: Int) {
        let lock = locks[absoluteIndex]!

        if lock.deferredLockRequests.isEmpty {
            lock.isLocked = false
            return
        }

        let request = lock.deferredLockRequests.popFront()
        engageGrid_D_onCenterCellLocked(request)
    }

    func connectSensorPad(_ lockRequest: GridLockRequest) {
        // We come here only after the requester has the center of
        // his sensor pad locked. So we skip that one here
        assert(lockRequest.unsafeCellConnectors[0]!.coreCell != nil)

        for localIx in 1..<lockRequest.cUnsafeCellConnectors {
            let cellDescriptor = lockRequest.unsafeCellConnectors[localIx]!
            let lock = self.locks[cellDescriptor.absoluteIndex]!

            // The mapper has filled out its sensor pad optimistically,
            // assuming all the cells it requests can be locked. Here we
            // give it the bad news about any it's not allowed to have, by
            // replacing non-locked descriptors with blind ones
            if lock.isLocked {
                let cc = GridCellConnector(cellDescriptor.absoluteIndex)
                lockRequest.unsafeCellConnectors[localIx] = cc
                continue
            }

            // Good news for the requester
            self.locks[cellDescriptor.absoluteIndex]!.isLocked = true
        }
    }

    func deferLockRequest(_ request: GridLockRequest) {
        locks[request.centerAbsoluteIndex]!.deferredLockRequests.pushBack(request)
    }

    func engageGrid_B_requestLock(_ request: GridLockRequest) {
        let centerLock = self.locks[request.centerAbsoluteIndex]!

        if centerLock.isLocked {
            self.deferLockRequest(request)
            return
        }

        engageGrid_C_onCenterCellAvailable(request)
    }

    func engageGrid_C_onCenterCellAvailable(_ request: GridLockRequest) {
        let centerCell = Grid.shared.cellAt(request.centerAbsoluteIndex)

        locks[request.centerAbsoluteIndex]!.isLocked = true
        request.unsafeCellConnectors[0] = centerCell
    }

    func engageGrid_D_onCenterCellLocked(_ request: GridLockRequest) {
        lockQueue.async {
            self.connectSensorPad(request)
            MainDispatchQueue.async(execute: request.onCellReady)
        }
    }
}
