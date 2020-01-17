import SpriteKit

class GridCell: GridCellProtocol, Equatable, CustomDebugStringConvertible {
    enum Contents: Double, CaseIterable {
        case arkon, invalid, manna, nothing

        var asNetSignal: Double {
            (self.rawValue + 1) / Double(Contents.allCases.count + 1)
        }

        var isEdible:       Bool { self == .arkon || self == .manna }
        var isOccupied:     Bool { self != .invalid && self != .nothing }
    }

    var debugDescription: String { return "GridCell.at(\(gridPosition.x), \(gridPosition.y))" }

    var coldKey: ColdKey?
    var dormantManna = [SKSpriteNode]()
    let gridPosition: AKPoint
    var isLocked = false
    var ownerName = "never owned"
    var randomScenePosition: CGPoint?
    var toReschedule = [Stepper]()
    let scenePosition: CGPoint

    private (set) var contents = Contents.nothing

    weak var sprite: SKSpriteNode?

    var isInDangerZone: Bool { Substrate.shared.isInDangerZone(self) }

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.gridPosition = gridPosition
        self.scenePosition = scenePosition

        coldKey = ColdKey(for: self)

        if Arkonia.funkyCells == false { return }

        let wScene = CGFloat(Substrate.shared.cPortal) / 2
        let hScene = CGFloat(Substrate.shared.rPortal) / 2

        let lScene = scenePosition.x - wScene
        let rScene = scenePosition.x + wScene
        let bScene = scenePosition.y - hScene
        let tScene = scenePosition.y + hScene

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
    func floatMannaIf() {
        guard self.contents == .nothing else { return }

        if let dormantMannaSprite = self.dormantManna.popFirst() {
            let a = SKAction.run { [unowned self] in
                Debug.log("float manna at \(self))", level: 86)
                self.contents = .manna
                self.sprite = dormantMannaSprite
                dormantMannaSprite.setContentsCallback?()
            }

            dormantMannaSprite.run(a)
        }
    }

    func injectManna(_ sprite: SKSpriteNode) {
        sprite.position = randomScenePosition ?? scenePosition
        dormantManna.append(sprite)
    }

    func setContents(
        to newContentType: Contents, newSprite: SKSpriteNode?,
        _ onComplete: @escaping () -> Void
    ) {
        func a() { Substrate.serialQueue.async(execute: b) }

        func b() {
            self.contents = newContentType
            self.sprite = newSprite

            guard self.contents == .nothing else { e(); return }

            if let dormantMannaSprite = self.dormantManna.popFirst() {
                self.contents = .manna
                self.sprite = dormantMannaSprite
                c(dormantMannaSprite)
                return
            }

            e()
        }

        func c(_ dormantMannaSprite: SKSpriteNode) {
            let a = SKAction.run { dormantMannaSprite.setContentsCallback?() }
            dormantMannaSprite.run(a)
            e()
        }

        func e() { onComplete() }

        a()
    }
}

extension GridCell {
    func descheduleIf(_ stepper: Stepper) {
        toReschedule.removeAll {
            let remove = $0.name == stepper.name
            if remove { Debug.log("deschedule \(six(stepper.name)) == \(six($0.name))", level: 62) }
            return remove
        }
    }

    func getRescheduledArkon() -> Stepper? {
        defer { if toReschedule.isEmpty == false { _ = toReschedule.removeFirst() } }

        if !toReschedule.isEmpty {
            Debug.log(
                "getRescheduledArkon \(six(toReschedule.first!.name)) " +
                "\(toReschedule.count)", level: 62
            )
        }
        return toReschedule.first
    }

    func reschedule(_ stepper: Stepper) {
        precondition(toReschedule.contains { $0.name == stepper.name } == false)
        toReschedule.append(stepper)
        Debug.debugColor(stepper, .blue, .red)
        Debug.log("reschedule \(six(stepper.name)) at \(self) toReschedule.count = \(toReschedule.count); \(gridPosition) owned by \(six(ownerName))", level: 71)
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

    func lock(require: RequireLock = .hot, ownerName: String) -> GridCellKey? {
//        precondition(self.ownerName != ownerName)
        Debug.log("lock for \(six(ownerName)) was \(six(self.ownerName))", level: 85)

        switch (self.isLocked, require) {
        case (true, .hot): fatalError()
        case (true, .degradeToNil): Debug.log("true, .degradeToNil", level: 85); return nil
        case (true, .degradeToCold): Debug.log("true, .degradeToCold", level: 85); return self.coldKey

        case (_, .cold): Debug.log("_, .cold", level: 85); return self.coldKey

        case (false, .degradeToCold): Debug.log("false, .degradeToCold", level: 80); fallthrough
        case (false, .degradeToNil): Debug.log("false, .degradeToNil", level: 80);  fallthrough
        case (false, .hot): Debug.log("false, .hot", level: 85); return HotKey(for: self, ownerName: ownerName)
        }
    }

    func releaseLock() -> Bool {
        Debug.log("GridCell.releaseLock \(six(ownerName)) at \(self)", level: 85)
//        indicator.run(SKAction.fadeOut(withDuration: 2.0))
        defer { isLocked = false; ownerName = "No owner" }
        return isLocked && !toReschedule.isEmpty
    }
}
