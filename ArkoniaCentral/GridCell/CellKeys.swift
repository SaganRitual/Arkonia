//swiftlint:disable unused_setter_value
import SpriteKit

protocol GridCellKey: class {
    var bell: GridCell? { get }
    var contents: GridCell.Contents { get }
    var gridPosition: AKPoint { get }
    var ownerName: String { get }
    var sprite: SKSpriteNode? { get }

    func getCell() -> GridCell?
    func reengageRequesters()
}

extension GridCellKey {
    func getCell() -> GridCell? { return bell }

    func reengageRequesters() {
        guard let c = bell else { return }

//        if let sp = self.sprite {
//            (sp.children[0] as? SKSpriteNode)?.color = .red
//            sp.color = .blue
//        }
        while true {
            guard let waitingStepper = c.getRescheduledArkon() else {
                Log.L.write("reengageRequesters empty", level: 54)
                return
            }
            if let dp = waitingStepper.dispatch, let st = dp.scratch.stepper {
                st.nose.color = .magenta
                Log.L.write("reengageRequesters: \(six(st.name)) at \(self.gridPosition)", level: 59)
                dp.disengage()
            }
        }
    }
}

class ColdKey: GridCellKey {
    private weak var cell_: GridCell?
    internal var bell: GridCell? { get { cell_ } set { preconditionFailure() } }

    init(for cell: GridCell) {
        self.cell_ = cell
    }

    var contents: GridCell.Contents {
        get { return cell_?.contents ?? .invalid }
        set { preconditionFailure() }
    }

    var gridPosition: AKPoint {
        get { return cell_?.gridPosition ?? AKPoint(x: -4242, y: -4242) }
        set { preconditionFailure() }
    }

    var ownerName: String {
        get { return cell_?.ownerName ?? "empty hotkey" }
        set { cell_?.ownerName = newValue }
    }

    var sprite: SKSpriteNode? {
        get { return cell_?.sprite }
        set { preconditionFailure() }
    }

    func reschedule(_ stepper: Stepper) { cell_?.reschedule(stepper) }
}

class HotKey: GridCellKey, CustomDebugStringConvertible {
    private weak var cell_: GridCell?
    var bell: GridCell? { get { cell_ } set { preconditionFailure() } }

    var debugDescription: String {
        "\(bell?.gridPosition ?? AKPoint(x: -4242, y: -4242))"
    }

    var contents: GridCell.Contents {
        get { return cell_?.contents ?? .invalid }
        set { cell_?.contents = newValue }
    }

    var gridPosition: AKPoint {
        get { return cell_?.gridPosition ?? AKPoint(x: -4242, y: -4242) }
        set { preconditionFailure() }
    }

    var scenePosition: CGPoint {
        get { return cell_?.scenePosition ?? CGPoint(x: -42.42, y: -42.42) }
        set { preconditionFailure() }
    }

    var ownerName: String {
        get { return cell_?.ownerName ?? "empty hotkey" }
        set { cell_?.ownerName = newValue }
    }

    var sprite: SKSpriteNode? {
        get { return cell_?.sprite }
        set { cell_?.sprite = newValue }
    }

    init(for cell: GridCell, ownerName: String) {
        self.cell_ = cell
        cell.isLocked = true
        cell.ownerName = ownerName
        Log.L.write("HotKey at \(cell.gridPosition) for \(six(ownerName))", level: 51)
    }

    deinit { releaseLock() }

    func deactivate() {
        Log.L.write("deactivate for \(six(ownerName))", level: 60)
        self.cell_ = nil }

    func releaseLock() {
        Log.L.write("releaseLock at \(cell_?.gridPosition ?? AKPoint(x: -42, y: -42)) for \(six(ownerName)) nil? \(cell_ == nil)", level: 56)
        cell_?.releaseLock()
        reengageRequesters()
        cell_ = nil
    }

    func transferKey(to winner: Stepper) {
        guard let c = cell_ else { fatalError() }
        precondition(c.isLocked)

        Log.L.write("transferKey from \(six(self.ownerName)) at \(gridPosition) to \(six(winner.name))", level: 59)

        self.ownerName = winner.name
        self.sprite = winner.sprite
    }
}

class NilKey: GridCellKey {
    //swiftlint:disable unused_setter_value
    var bell: GridCell? { get { nil } set { preconditionFailure() } }
    var contents: GridCell.Contents { get { .invalid } set { preconditionFailure() } }
    var gridPosition: AKPoint { get { AKPoint(x: -4242, y: -4242) } set { preconditionFailure() } }
    var ownerName: String { get { "invalid" } set { preconditionFailure() } }
    var sprite: SKSpriteNode?  { get { nil } set { preconditionFailure() } }
    //swiftlint:enable unused_setter_value
}
