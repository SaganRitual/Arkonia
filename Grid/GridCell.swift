import SpriteKit

class GridCell: GridCellProtocol, Equatable, CustomDebugStringConvertible {
    enum Contents: Double, CaseIterable {
        case arkon, invalid, nothing

        var asNetSignal: Double {
            (self.rawValue + 1) / Double(Contents.allCases.count + 1)
        }

//        var isEdible:       Bool { self == .arkon || self == .manna }
        var isOccupied:     Bool { self != .invalid && self != .nothing }
    }

    lazy var debugDescription: String = { String(format: "GridCell.at(% 03d, % 03d)", gridPosition.x, gridPosition.y) }()

    var coldKey: ColdKey?
    let gridPosition: AKPoint
    var isLocked = false
    var ownerName = "never owned"
    var randomScenePosition: CGPoint?
    var toReschedule = [Stepper]()
    let scenePosition: CGPoint

    private (set) var contents = Contents.nothing

    var manna: Manna?
    weak var stepper: Stepper?

    var isInDangerZone: Bool { Grid.shared.isInDangerZone(self) }

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.gridPosition = gridPosition
        self.scenePosition = scenePosition

        coldKey = ColdKey(for: self)

        guard let funkyMultiplier = Arkonia.funkyCells else { return }

        let wScene = CGFloat(Grid.shared.cPortal) / 2
        let hScene = CGFloat(Grid.shared.rPortal) / 2

        let lScene = scenePosition.x - wScene * funkyMultiplier
        let rScene = scenePosition.x + wScene * funkyMultiplier
        let bScene = scenePosition.y - hScene * funkyMultiplier
        let tScene = scenePosition.y + hScene * funkyMultiplier

        self.randomScenePosition = CGPoint.random(
            xRange: lScene..<rScene, yRange: bScene..<tScene
        )

//        self.indicator = SpriteFactory.shared.noseHangar.makeSprite()
//        self.indicator.position = scenePosition
//        self.indicator.color = .white
//        self.indicator.alpha = 0
//        self.indicator.setScale(0.3)
//        GriddleScene.arkonsPortal.addChild(self.indicator)
    }
}

extension GridCell {
    func clearContents() {
        Debug.log(level: 109) { "clearContents \(six(stepper?.name)) at \(gridPosition)" }

        assert(self.contents == .arkon) // No more manna as variable contents

        self.contents = .nothing
        self.stepper = nil
    }

    func setContents(to stepper: Stepper?) {
        Debug.log(level: 109) {
            "setContent for \(six(stepper?.name)) at \(gridPosition) replacing \(six(stepper?.name))"
        }

        self.contents = .arkon
        self.stepper = stepper
    }
}

extension GridCell {
    func descheduleIf(_ stepper: Stepper) {
        toReschedule.removeAll {
            let name = $0.name
            let remove = $0.name == stepper.name
            if remove {
                Debug.log(level: 146) { "deschedule \(six(stepper.name)) == \(six(name))" }
            }
            return remove
        }
    }

    func getRescheduledArkon() -> Stepper? {
        defer { if toReschedule.isEmpty == false { _ = toReschedule.removeFirst() } }

        if !toReschedule.isEmpty {
            Debug.log(level: 146) {
                "getRescheduledArkon \(six(toReschedule.first!.name)) " +
                "\(toReschedule.count)"
            }
        }
        return toReschedule.first
    }

    func reschedule(_ stepper: Stepper) {
        precondition(toReschedule.contains { $0.name == stepper.name } == false)
        let count = HotKey.countRescheduledArkons(more: true)
        toReschedule.append(stepper)
        Debug.debugColor(stepper, .blue, .red)
        Debug.log(level: 157) { "reschedule \(count) \(six(stepper.name)) at \(self) toReschedule.count = \(toReschedule.count); \(gridPosition) owned by \(six(ownerName))" }
    }
}

extension GridCell {
    typealias LockComplete = (GridCellKey?) -> Void

    enum RequireLock { case cold, degradeToCold, degradeToNil, hot }

    func lockIf(ownerName: String) -> HotKey? {
        if isLocked { return nil }
        guard let key = lock(require: .degradeToNil, ownerName: ownerName) as? HotKey
            else { fatalError() }

        return key
    }

    func lockIfEmpty(ownerName: String) -> HotKey? {
        if contents.isOccupied { return nil }
        return lockIf(ownerName: ownerName)
    }

    func lock(require: RequireLock = .hot, ownerName: String) -> GridCellKey? {
//        precondition(self.ownerName != ownerName)
        Debug.log(level: 85) { "lock for \(six(ownerName)) was \(six(self.ownerName))" }

        switch (self.isLocked, require) {
        case (true, .hot): fatalError()
        case (true, .degradeToNil): Debug.log(level: 85) { "true, .degradeToNil" }; return nil
        case (true, .degradeToCold): Debug.log(level: 85) { "true, .degradeToCold" }; return self.coldKey

        case (_, .cold): Debug.log(level: 85) { "_, .cold" }; return self.coldKey

        case (false, .degradeToCold): Debug.log(level: 80) { "false, .degradeToCold" }; fallthrough
        case (false, .degradeToNil): Debug.log(level: 80) { "false, .degradeToNil" };  fallthrough
        case (false, .hot): Debug.log(level: 85) { "false, .hot" }; return HotKey(for: self, ownerName: ownerName)
        }
    }

    @discardableResult
    func releaseLock() -> Bool {
        Debug.log(level: 85) { "GridCell.releaseLock \(six(ownerName)) at \(self)" }
//        indicator.run(SKAction.fadeOut(withDuration: 2.0))
        defer { isLocked = false; ownerName = "No owner" }
        return isLocked && !toReschedule.isEmpty
    }
}
