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
    var requesters = [Dispatch]()
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
            Log.L.write("GridCell \(self): not locked; return nil", level: 32)
            precondition(require == false)
            return ColdKey(for: self)
        }

        Log.L.write("GridCell \(self): locked; return self", level: 32)
        return HotKey(for: self)
    }

    func releaseLock() {
        isLocked = false

        var requester: Dispatch?
        while !requesters.isEmpty {
            requester = requesters.removeFirst()
            if requester?.scratch.stepper == nil { requester = nil }
            else { break }
        }

        if requester != nil {
            Log.L.write("GridCell \(self): release lock, start requester", level: 32)
        }

        requester?.engage()
    }
}
