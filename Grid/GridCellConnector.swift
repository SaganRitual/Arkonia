import Foundation

struct GridCellConnector: CustomDebugStringConvertible {
    let absoluteIndex: Int

    let coreCell: GridCell?
    let virtualScenePosition: CGPoint?  // For asteroids-style wraparound movement

    var debugDescription: String {
        ((coreCell == nil) ? "Cold" : "Hot(\(absoluteIndex))")
    }

    init(_ coreCell: GridCell?, _ absoluteIndex: Int, _ virtualScenePosition: CGPoint?) {
        // coreCell == nil means we coulnd't lock the cell, which means that although
        // we know it's there, we can't see inside it, and we can't jump to it
        self.coreCell = coreCell

        self.absoluteIndex = absoluteIndex
        self.virtualScenePosition = virtualScenePosition
    }

    init(_ coreCell: GridCell, _ virtualScenePosition: CGPoint? = nil) {
        self.coreCell = coreCell
        self.absoluteIndex = coreCell.absoluteIndex
        self.virtualScenePosition = virtualScenePosition
    }

    init(_ absoluteIndex: Int, _ virtualScenePosition: CGPoint? = nil) {
        self.coreCell = nil
        self.absoluteIndex = absoluteIndex
        self.virtualScenePosition = virtualScenePosition
    }
}
