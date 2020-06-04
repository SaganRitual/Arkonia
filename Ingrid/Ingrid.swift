import Foundation

class Ingrid {
    static var shared: Ingrid!

    let core: IngridCore

    let nonCriticalsQueue = DispatchQueue(
        label: "ak.grid.concurrent", attributes: .concurrent, target: DispatchQueue.global()
    )

    let lockQueue = DispatchQueue(
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
    }

    func completeDeferredLockRequest(for readyCell: IngridCell) {
        if readyCell.waitingLockRequests.isEmpty { return }

        let engagerSpec = readyCell.waitingLockRequests.popFront()

        core.engageSensorPad(engagerSpec)
        engagerSpec.onComplete()
    }

    func deferLockRequest(_ engagerSpec: EngagerSpec) {
        let cell = core.getCell(at: engagerSpec.center)
        cell.waitingLockRequests.pushBack(engagerSpec)
    }

    func disengage(
        pad: UnsafeMutablePointer<IngridCellDescriptor>,
        padCCells: Int,
        keepTheseCells absoluteIndices: [Int],
        _ onComplete: @escaping () -> Void
    ) {
        lockQueue.async { [core] in
            core.disengage(
                pad: pad, padCCells: padCCells,
                keepTheseCells: absoluteIndices
            ) { readyCell in self.completeDeferredLockRequest(for: readyCell) }

            self.nonCriticalsQueue.async(execute: onComplete)
        }
    }

    func engageSensorPad(_ engagerSpec: EngagerSpec) {
        lockQueue.async { [core] in
            let isEngaged = core.engageSensorPad(engagerSpec)

            if isEngaged { engagerSpec.onComplete(); return }

            self.deferLockRequest(engagerSpec)
        }
    }
}
