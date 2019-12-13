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
    var debugReport = [String]()

    var contents = Contents.nothing
    weak var sprite: SKSpriteNode?

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.gridPosition = gridPosition
        self.scenePosition = scenePosition
    }
}

extension GridCell {
    func descheduleIf(_ stepper: Stepper) {
        toReschedule.removeAll {
            let remove = $0.name == stepper.name
            if remove { Log.L.write("deschedule \(six(stepper.name)) == \(six($0.name))", level: 59) }
            return remove
        }
    }

    func getRescheduledArkon() -> Stepper? {
        defer { if toReschedule.isEmpty == false { _ = toReschedule.removeFirst() } }

        Log.L.write("getRescheduledArkon \(toReschedule.count)", level: 51)
        return toReschedule.first
    }

    func reschedule(_ stepper: Stepper) {
        precondition(toReschedule.contains { $0.name == stepper.name } == false)
        toReschedule.append(stepper)
        stepper.nose.color = .blue
        Log.L.write("reschedule \(six(stepper.name)) at \(self) toReschedule.count = \(toReschedule.count); \(gridPosition) owned by \(six(ownerName))", level: 52)
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
        Log.L.write("GridCell.releaseLock \(six(ownerName)) at \(self)", level: 51)
        isLocked = false; ownerName = "No owner"
    }
}
