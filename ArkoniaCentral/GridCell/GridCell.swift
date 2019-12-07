import SpriteKit

class GridCell: GridCellProtocol, Equatable, CustomDebugStringConvertible {
    enum Contents: Double, CaseIterable {
        case arkon, invalid, manna, nothing

        func isEdible() -> Bool {
            return self == .arkon || self == .manna
        }

        func isOccupied() -> Bool {
            return self == .arkon || self == .manna
        }
    }

    var debugDescription: String { return "GridCell.at(\(gridPosition.x), \(gridPosition.y))" }

    let gridPosition: AKPoint
    var isLocked = false
    var randomScenePosition: CGPoint?
    let scenePosition: CGPoint

    var contents = Contents.nothing
    weak var sprite: SKSpriteNode?

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.gridPosition = gridPosition
        self.scenePosition = scenePosition
    }
}

extension GridCell {
    func lock(require: Bool = true) -> GridCellKey {
        defer { isLocked = true }

        if isLocked {
            Log.L.write("GridCell \(self): not locked; return nil", level: 37)
            precondition(require == false)
            return ColdKey(for: self)
        }

        Log.L.write("GridCell \(self): locked; return self", level: 37)
        return HotKey(for: self)
    }

    func releaseLock() { isLocked = false }
}
