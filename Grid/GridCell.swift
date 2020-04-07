import SpriteKit

protocol GridCellProtocol {
    var gridPosition: AKPoint { get }
    var manna: Manna? { get }
    var ownerName: ArkonName { get }
    var stepper: Stepper? { get }
}

class GridCell: GridCellProtocol, Equatable, CustomDebugStringConvertible {

    lazy var debugDescription: String = { String(format: "GridCell.at(% 03d, % 03d)", gridPosition.x, gridPosition.y) }()

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
        toReschedule.append(stepper)
        Debug.debugColor(stepper, .blue, .red)
    }
}

extension GridCell {
    enum RequireLock { case cold, degradeToCold, degradeToNil, hot }

    func lockIf(ownerName: ArkonName, _ catchDumbMistakes: DispatchQueueID) -> GridCell? {
        if isLocked { return nil }
        guard let key = lock(require: .degradeToNil, ownerName: ownerName, catchDumbMistakes) as? GridCell
            else { fatalError() }

        return key
    }

    func lockIfEmpty(ownerName: ArkonName, _ catchDumbMistakes: DispatchQueueID) -> GridCell? {
        if stepper != nil { return nil }
        return lockIf(ownerName: ownerName, catchDumbMistakes)
    }

    func lock(require: RequireLock = .hot, ownerName: ArkonName, _ catchDumbMistakes: DispatchQueueID) -> GridCellProtocol? {
        assert(catchDumbMistakes == .arkonsPlane)

        lockTime = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)

        let key: GridCellProtocol?
        switch (self.isLocked, require) {
        case (true, .hot):           fatalError()
        case (true, .degradeToNil):  key = nil
        case (true, .degradeToCold): key = ColdKey(for: self)

        case (_, .cold):             key = ColdKey(for: self)

        case (false, _):             isLocked = true; self.ownerName = ownerName; key = self
        }

        Debug.log(level: 167) { "Lock attempt at \(six(key?.gridPosition)) by \(ownerName) got G \(key is GridCell) C \(key is ColdKey) N \(key is NilKey) n \(key == nil)" }
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
        assert(dispatchQueueID == .arkonsPlane)

        // Allows us to release the lock without caring whether we
        // really have a lock. Seems ugly, look into it
        if ownerName.nametag == .nothing { return false }

        debugStats()
        Debug.log(level: 167) { "GridCell.releaseLock \(six(ownerName)) at \(self)" }
//        assert(ownerName.nametag != .nothing)
//        indicator.run(SKAction.fadeOut(withDuration: 2.0))
        defer { isLocked = false; ownerName = ArkonName.empty }
        reengageRequesters()
        return isLocked && !toReschedule.isEmpty
    }
}
