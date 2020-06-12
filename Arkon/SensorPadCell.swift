import Foundation

class SensorPadCell {
    var iHaveTheLock = false
    var liveGridCell: GridCell!
    let padLocalIndex: Int
    var virtualGridPosition: AKPoint?

    var gridAbsoluteIndex: Int? { liveGridCell?.properties.gridAbsoluteIndex }

    init(_ padLocalIndex: Int) { self.padLocalIndex = padLocalIndex }

    func invalidate() -> Int? {
        defer {
            self.iHaveTheLock = false
            self.liveGridCell = nil
            self.virtualGridPosition = nil
        }

        return self.iHaveTheLock ? self.gridAbsoluteIndex : nil
    }

    func mapToGrid(centerOfPad centerAbsoluteGridIndex: Int) {
        let padCenterPosition = Grid.gridPosition(of: centerAbsoluteGridIndex)

        let targetPosition = Grid.localIndexToVirtualGrid(
            center: padCenterPosition, localIx: padLocalIndex
        )

        let absoluteGridIndex: Int
        let virtualGridPosition: AKPoint?

        if let asteroidizedAbsoluteIndex = Grid.asteroidize(targetPosition) {
            absoluteGridIndex = asteroidizedAbsoluteIndex
            virtualGridPosition = targetPosition
        } else {
            absoluteGridIndex = Grid.absoluteIndex(of: targetPosition)
            virtualGridPosition = nil
        }

        self.liveGridCell = Grid.cellAt(absoluteGridIndex)

        mapToGrid(
            at: absoluteGridIndex, lockAcquired: false,
            virtualGridPosition: virtualGridPosition
        )
    }

    private func mapToGrid(at absoluteIndex: Int, lockAcquired: Bool, virtualGridPosition: AKPoint?) {
        self.iHaveTheLock = lockAcquired
        self.liveGridCell = Grid.cellAt(absoluteIndex)
        self.virtualGridPosition = virtualGridPosition
    }
}
