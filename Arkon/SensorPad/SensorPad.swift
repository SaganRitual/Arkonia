import Foundation

typealias UnsafeCellConnectors = UnsafeMutablePointer<GridCellConnector?>

class SensorPad {
    let cCells: Int
    var centerAbsoluteIndex = 0
    let unsafeCellConnectors: UnsafeCellConnectors

    var centerGridPoint: AKPoint { Grid.shared.bareCellAt(centerAbsoluteIndex).gridPosition }

    static func makeSensorPad(_ cCells: Int) -> SensorPad { return .init(cCells) }

    private init(_ cCells: Int) {
        self.cCells = cCells

        self.unsafeCellConnectors = .allocate(capacity: cCells)
        self.unsafeCellConnectors.initialize(repeating: nil, count: cCells)
    }
}

extension SensorPad {
    @discardableResult
    func invalidateCell(_ localPadIx: Int) -> Int? {
        // If we don't have a hot connection to the cell, we don't
        // need to do anything to it
        guard unsafeCellConnectors[localPadIx]!.isHot else { return nil }

        let absoluteCellIx = Grid.shared.localIndexToGridAbsolute(centerGridPoint, localPadIx)

        // Invalidate the caller's pad so he won't think he can just
        // come back and mess about the place
        unsafeCellConnectors[localPadIx] = GridCellConnector(absoluteCellIx)

        return absoluteCellIx
    }

    func invalidateToShuttle(_ keepLocalIndex: Int) -> [Int] {
        return (1..<cCells).compactMap {
            $0 == 0 || $0 == keepLocalIndex ? nil : invalidateCell($0)
        }
    }

    // Release all the cells in the sensor pad that won't be involved in the
    // jump. The "shuttle" refers to the two cells remaining, which will always
    // be the center, at [0], and some other locked cell in the pad
    func pruneToShuttle(_ keepLocalIndex: Int) {
        let absoluteIndexesToRelease = invalidateToShuttle(keepLocalIndex)
        Grid.shared.releaseCells(absoluteIndexesToRelease)
    }
}

extension SensorPad {
    func disengageGrid() {
        let absoluteIndexesToUnlock: [Int] = (0..<cCells).compactMap {
            self.invalidateCell($0)
            return unsafeCellConnectors[$0]!.coreCell?.absoluteIndex
        }

        Grid.shared.releaseCells(absoluteIndexesToUnlock)
    }

    func engageGrid(_ onComplete: @escaping () -> Void) {
        mapSensorPadToGrid()

        let lockRequest = GridLockRequest(self, onComplete)
        Grid.shared.engageGrid(lockRequest)
    }

    private func mapSensorPadToGrid() {
        for ss in 1..<cCells {
            let virtualGridPoint = Grid.shared.localIndexToVirtualGrid(ss)
            let jumpTarget = Grid.shared.core.correctForDisjunction(virtualGridPoint)

            let checkTeleportation = virtualGridPoint + centerGridPoint
            let teleportationTarget: CGPoint? = (checkTeleportation == jumpTarget) ?
                jumpTarget.asPoint() : nil

            let cell = Grid.shared.bareCellAt(jumpTarget)

            unsafeCellConnectors[ss] = GridCellConnector(cell, teleportationTarget)
        }
    }
}
