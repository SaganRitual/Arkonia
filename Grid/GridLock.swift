import Foundation
import SpriteKit

class GridLock {
    static let lockQueue = DispatchQueue(
        label: "ak.gridlock.q", target: DispatchQueue.global()
    )

    var isLocked = false

    // I'd be surprised if it ever goes past 2
    // 2020.07.25: I'm surprised because it went past 5
    fileprivate let occupancyDeferrals = Cbuffer<Deferral>(cElements: 10, mode: .fifo)
    fileprivate var occupantLockDeferral: Deferral?
}

extension GridLock {
    func deferRequest(
        for cell: GridCell,
        normalLock: Bool,
        gridIsLocked: Bool,
        _ onLocked: @escaping () -> Void
    ) {
        assert(gridIsLocked)

        let deferral = Deferral(for: cell, normalLock: normalLock, onLocked)

        // "Normal" meaning the occupant of the cell is requesting the lock
        // so he can forage for food
        if normalLock {
            hardAssert(self.occupantLockDeferral == nil) { nil }
            Debug.log(level: 218) { "occupantLockDeferral at \(cell.properties.gridPosition)" }
            self.occupantLockDeferral = deferral
        }

        // "Not normal" meaning this is a supernatural birth from the sky and
        // the coming newborn needs its landing cell to be locked so it can land
        else {
            Debug.log(level: 218) { "occupancyDeferrals at \(cell.properties.gridPosition)" }
            cell.lock.occupancyDeferrals.pushBack(deferral) }
    }

    func releaseLock(_ cellIsOccupied: Bool) { self.serviceDeferrals(cellIsOccupied) }
}

private extension GridLock {
    struct Deferral {
        let cell: GridCell
        let normalLock: Bool
        let onLocked: () -> Void

        init(for cell: GridCell, normalLock: Bool, _ onLocked: @escaping () -> Void) {
            self.cell = cell
            self.normalLock = normalLock
            self.onLocked = onLocked
        }

        func redeploy() { onLocked() }
    }

    func serviceDeferrals(_ cellIsOccupied: Bool) {
        GridLock.lockQueue.async { serviceDeferrals_A() }

        func serviceDeferrals_A() {
            // Prirority goes to an arkon already in the cell, he'll be awaiting
            // some other arkon releasing the lock
            if occupantLockDeferral == nil { serviceDeferrals_B() }
            else                           { serviceDeferrals_C() }
        }

        func serviceDeferrals_B() {
            Debug.log(level: 217) { "serviceDeferrals_B \(self.occupancyDeferrals.count)" }
            // If there's nothing in the defer list, then of course we're finished.
            // But if there's someone sitting in the cell still, we can't do
            // anything. We're stuck on the defer list until that guy moves,
            // which in most cases will be in the next cycle
            if occupancyDeferrals.isEmpty || cellIsOccupied {
                self.isLocked = false
                return
            }

            occupancyDeferrals.popFront().redeploy()
        }

        func serviceDeferrals_C() {
            Debug.log(level: 217) { "serviceDeferrals_C \(self.occupancyDeferrals.count)" }
            occupantLockDeferral!.redeploy(); occupantLockDeferral = nil; return
        }
    }
}
