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
    var ownerName = "never owned"
    var randomScenePosition: CGPoint?
    var toReschedule = [Stepper]()
    let scenePosition: CGPoint

    var contents = Contents.nothing
    weak var sprite: SKSpriteNode?

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.gridPosition = gridPosition
        self.scenePosition = scenePosition
    }
}

extension GridCell {
    func getRescheduledArkon() -> Stepper? {
        defer { if toReschedule.isEmpty == false { _ = toReschedule.removeFirst() } }

        Log.L.write("getRescheduledArkon \(toReschedule.count)", level: 49)
        return toReschedule.first
    }

    func reschedule(_ stepper: Stepper) {
        toReschedule.append(stepper)
        Log.L.write("reschedule \(six(stepper.name)) \(toReschedule.count)", level: 49)
    }
}

extension GridCell {
    typealias LockComplete = (GridCellKey) -> Void

    func lock(require: Bool = true, ownerName: String, onComplete: @escaping LockComplete) {
        if isLocked {
            onComplete(ColdKey(for: self))
            return
        }

        onComplete(HotKey(for: self, ownerName: ownerName))
    }

    func releaseLock() {
        Log.L.write("GridCell.releaseLock \(six(ownerName))", level: 49)
        isLocked = false; ownerName = "No owner"
    }
}
