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
//    let indicator: SKSpriteNode

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.gridPosition = gridPosition
        self.scenePosition = scenePosition

//        self.indicator = SpriteFactory.shared.noseHangar.makeSprite()
//        self.indicator.position = scenePosition
//        self.indicator.color = .white
//        self.indicator.alpha = 0
//        self.indicator.setScale(0.3)
//        GriddleScene.arkonsPortal.addChild(self.indicator)
    }
}

extension GridCell {
    func descheduleIf(_ stepper: Stepper) {
        toReschedule.removeAll {
            let remove = $0.name == stepper.name
            if remove { Log.L.write("deschedule \(six(stepper.name)) == \(six($0.name))", level: 62) }
            return remove
        }
    }

    func getRescheduledArkon() -> Stepper? {
        defer { if toReschedule.isEmpty == false { _ = toReschedule.removeFirst() } }

        if !toReschedule.isEmpty { Log.L.write("getRescheduledArkon \(six(toReschedule.first!.name)) \(toReschedule.count)", level: 62) }
        return toReschedule.first
    }

    func reschedule(_ stepper: Stepper) {
        precondition(toReschedule.contains { $0.name == stepper.name } == false)
        toReschedule.append(stepper)
        debugColor(stepper, .blue, .red)
        Log.L.write("reschedule \(six(stepper.name)) at \(self) toReschedule.count = \(toReschedule.count); \(gridPosition) owned by \(six(ownerName))", level: 61)
    }
}

extension GridCell {
    typealias LockComplete = (GridCellKey) -> Void

    func lock(require: Bool = true, ownerName: String, onComplete: @escaping LockComplete) {
        if isLocked {
//            indicator.color = .blue
//            indicator.alpha = 1
            onComplete(ColdKey(for: self))
            return
        }

//        indicator.color = .red
//        indicator.alpha = 1
        onComplete(HotKey(for: self, ownerName: ownerName))
    }

    func releaseLock() -> Bool {
        Log.L.write("GridCell.releaseLock \(six(ownerName)) at \(self)", level: 62)
//        indicator.run(SKAction.fadeOut(withDuration: 2.0))
        defer { isLocked = false; ownerName = "No owner" }
        return isLocked && !toReschedule.isEmpty
    }
}
