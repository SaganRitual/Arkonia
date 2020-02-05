//swiftlint:disable unused_setter_value
import SpriteKit

protocol GridCellKey {
    var contents: GridCell.Contents { get }
    var gridPosition: AKPoint { get }
    var ownerName: String { get }
    var sprite: SKSpriteNode? { get }
}

struct ColdKey: GridCellKey {
    init(for cell: GridCell) {
        contents = cell.contents
        gridPosition = cell.gridPosition
        ownerName = cell.ownerName
        sprite = cell.sprite
    }

    let contents: GridCell.Contents
    let gridPosition : AKPoint
    let ownerName: String
    let sprite: SKSpriteNode?
}

class HotKey: GridCellKey, CustomDebugStringConvertible {
    private weak var cell_: GridCell?
    var bell: GridCell? { get { cell_ } set { fatalError() } }
    var isLive = true

    var debugDescription: String {
        "\(bell?.gridPosition ?? AKPoint(x: -4242, y: -4242))"
    }

    var contents: GridCell.Contents {
        get { return cell_?.contents ?? .invalid }
    }

    var gridPosition: AKPoint {
        get { return cell_!.gridPosition }
        set { fatalError() }
    }

    var randomScenePosition: CGPoint? {
        get { return cell_?.randomScenePosition }
        set { fatalError() }
    }

    var scenePosition: CGPoint {
        get { return cell_?.scenePosition ?? CGPoint(x: -42.42, y: -42.42) }
        set { fatalError() }
    }

    var ownerName: String {
        get { return cell_?.ownerName ?? "empty hotkey" }
        set { cell_?.ownerName = newValue }
    }

    var sprite: SKSpriteNode? {
        get { return cell_?.sprite }
    }

    init(for cell: GridCell, ownerName: String) {
        self.cell_ = cell
        cell.isLocked = true
        cell.ownerName = ownerName
        Debug.log(level: 85) { "HotKey at \(cell.gridPosition) for \(six(ownerName))" }

        cell.coldKey = ColdKey(for: cell)
    }

    deinit {
        // Releasing the HotKey involves the HotKey itself. So we have to tell
        // it to shut down before we reach deinit
        assert(cell_ == nil)
    }

    func reengageRequesters() {
        guard let c = bell else { return }

        Debug.log(level: 105) {
            return c.toReschedule.isEmpty ? nil :
            "Reengage from \(c.toReschedule.count) requesters at \(gridPosition)"
        }

        while let waitingStepper = c.getRescheduledArkon() {
            if let dp = waitingStepper.dispatch, let st = dp.scratch.stepper {
                let ch = dp.scratch
                assert(ch.engagerKey == nil)
                Debug.log(level: 107) { "reengageRequesters: \(six(st.name)) at \(self.gridPosition); from \(ch.cellShuttle?.fromCell?.gridPosition ?? AKPoint.zero), to \(ch.cellShuttle?.toCell?.gridPosition ?? AKPoint.zero)" }
                dp.disengage()
                return
            }
        }
    }

    func releaseLock(serviceRequesters: Bool = true) {
        cell_?.releaseLock()
        if serviceRequesters { reengageRequesters() }
        cell_ = nil
    }

    func transferKey(to winner: Stepper, _ onComplete: @escaping () -> Void) {
        guard let c = cell_ else { fatalError() }
        precondition(c.isLocked)

        Debug.log(level: 71) { "transferKey from \(six(self.ownerName)) at \(gridPosition) to \(six(winner.name))" }

        self.ownerName = winner.name
        Debug.log(level: 104) { "setContents from transferKey in \(c.gridPosition)" }
        c.setContents(to: .arkon, newSprite: winner.sprite)
        if winner.dispatch.scratch.engagerKey != nil { releaseLock() }
        Debug.log(level: 104) { "setContents from transferKey out \(c.gridPosition)" }
        onComplete()
    }
}

class NilKey: GridCellKey {
    //swiftlint:disable unused_setter_value
    var bell: GridCell? { get { nil } set { fatalError() } }
    var contents: GridCell.Contents { get { .invalid } set { fatalError() } }
    var gridPosition: AKPoint { get { AKPoint(x: -4444, y: -4444) } set { fatalError() } }
    var ownerName: String { get { "invalid" } set { fatalError() } }
    var sprite: SKSpriteNode?  { get { nil } set { fatalError() } }
    //swiftlint:enable unused_setter_value
}
