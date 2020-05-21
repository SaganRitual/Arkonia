import SpriteKit

func six(_ key: GridCell?) -> String { key == nil ? "<nil>" : "\(six(key!.gridPosition)) tenant \(six(key!.stepper?.name)), owned by \(six(key!.ownerName))" }

protocol GridCellProtocol: CustomDebugStringConvertible {
    var gridPosition: AKPoint { get }
    var manna: Manna? { get }
    var ownerName: ArkonName { get }
    var stepper: Stepper? { get }
}

class GridCell: GridCellProtocol, Equatable {

    lazy var debugDescription: String = { String(format: "GridCell(\(gridPosition))") }()

    let gridPosition: AKPoint
    var isLocked = false
    var ownerName = ArkonName.empty
    var randomScenePosition: CGPoint?
    var toReschedule = [Stepper]()
    let scenePosition: CGPoint

    var manna: Manna?
    var mannaAwaitingRebloom = false
    weak var stepper: Stepper?

    var lockTime: __uint64_t = 0
    var releaseTime: __uint64_t = 0

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.gridPosition = gridPosition
        self.scenePosition = scenePosition

        guard let funkyMultiplier = Arkonia.funkyCells else { return }

        let wScene = CGFloat(Grid.shared.gridCellWidthInPix) / 2
        let hScene = CGFloat(Grid.shared.gridCellHeightInPix) / 2

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
    enum RequireLock { case cold, degradeToCold, degradeToNil, hot }

    func lockIf(ownerName: ArkonName, _ catchDumbMistakes: DispatchQueueID) -> GridCell? {
        if isLocked { return nil }

        let key = (lock(require: .degradeToNil, ownerName: ownerName, catchDumbMistakes) as? GridCell)!
        return key
    }

    func lockIfEmpty(ownerName: ArkonName, _ catchDumbMistakes: DispatchQueueID) -> GridCell? {
        if stepper != nil { return nil }
        return lockIf(ownerName: ownerName, catchDumbMistakes)
    }

    func lock(require: RequireLock = .hot, ownerName: ArkonName, _ catchDumbMistakes: DispatchQueueID) -> GridCellProtocol? {
        hardAssert(catchDumbMistakes == .arkonsPlane)   // Make sure we're on the right dispatch queue
        hardAssert(self.ownerName != ownerName)         // Make sure we're not trying to lock a cell we already own

        lockTime = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)

        let key: GridCellProtocol?
        switch (self.isLocked, require) {
        case (true, .hot):           fatalError()
        case (true, .degradeToNil):  key = nil
        case (true, .degradeToCold): key = ColdKey(for: self)

        case (_, .cold):             key = ColdKey(for: self)

        case (false, _):             isLocked = true; self.ownerName = ownerName; key = self
        }

        #if DEBUG
        Debug.log(level: 166) {
            "Lock attempt at \(six(key?.gridPosition))"
            + " by \(ownerName) got G \(key is GridCell)"
            + " C \(key is ColdKey) N \(key is NilKey)"
            + " n \(key == nil)"
        }
        #endif

        return key
    }

    func debugStats() {
        releaseTime = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
        let duration = constrain(Double(releaseTime - lockTime) / 1e10, lo: 0, hi: 1)

//        if stepper.name == ArkonName(nametag: .alice, setNumber: 0) {
        if duration > 0.1 {
//            Debug.histogrize(Double(duration), scale: 10, inputRange: 0..<1)
        }
    }

    @discardableResult
    func releaseLock(_ dispatchQueueID: DispatchQueueID) -> Bool {
        hardAssert(dispatchQueueID == .arkonsPlane)

        hardAssert(ownerName != ArkonName.empty)

//        debugStats()
        Debug.log(level: 168) { "GridCell.releaseLock \(six(ownerName)) at \(self)" }
//        indicator.run(SKAction.fadeOut(withDuration: 2.0))
        defer { isLocked = false; ownerName = ArkonName.empty }

        reengageRequesters(dispatchQueueID)
        return isLocked && !toReschedule.isEmpty
    }
}
