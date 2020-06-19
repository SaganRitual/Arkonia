import Foundation

struct IngridCellConnector: CustomDebugStringConvertible {
    let absoluteIndex_: Int?

    // Makes default-initialized cell descriptors unusable, so I don't
    // end up freeing the wrong locks or other such nastiness
    var absoluteIndex: Int { absoluteIndex_! }

    let coreCell: GridCell?
    let virtualScenePosition: CGPoint?  // For asteroids-style wraparound movement

    var debugDescription: String {
        ((coreCell == nil) ? "Cold" : "Hot(\(absoluteIndex))")
    }

    init() {
        absoluteIndex_ = nil
        coreCell = nil
        virtualScenePosition = nil
        Debug.log(level: 200) { "empty cell descriptor" }
    }

    init(_ coreCell: GridCell?, _ absoluteIndex: Int, _ virtualScenePosition: CGPoint?) {
        // coreCell == nil means we coulnd't lock the cell, which means that although
        // we know it's there, we can't see inside it, and we can't jump to it
        self.coreCell = coreCell

        self.absoluteIndex_ = absoluteIndex
        self.virtualScenePosition = virtualScenePosition
    }

    init(_ coreCell: GridCell, _ virtualScenePosition: CGPoint? = nil) {
        self.coreCell = coreCell
        self.absoluteIndex_ = coreCell.absoluteIndex
        self.virtualScenePosition = virtualScenePosition
    }

    init(_ absoluteIndex: Int, _ virtualScenePosition: CGPoint? = nil) {
        self.coreCell = nil
        self.absoluteIndex_ = absoluteIndex
        self.virtualScenePosition = virtualScenePosition
    }
}
