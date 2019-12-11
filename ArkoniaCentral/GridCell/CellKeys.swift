import SpriteKit

protocol GridCellKey: class {
    var cell: GridCell? { get }
    var contents: GridCell.Contents { get }
    var ownerName: String { get }
    var sprite: SKSpriteNode? { get }

    func reengageRequesters()
}

extension GridCellKey {
    func reengageRequesters() {
        guard let c = cell else { Log.L.write("rr1:", level: 49); return }

        while true {
            guard let st = c.getRescheduledArkon() else { Log.L.write("rr2:", level: 49); return }
            Log.L.write("reengageRequesters: \(six(st.name))", level: 49)
            if let dp = st.dispatch { dp.disengage() }
        }
    }
}

class ColdKey: GridCellKey {
    internal weak var cell: GridCell?
    internal let contents: GridCell.Contents
    internal let ownerName: String
    internal weak var sprite: SKSpriteNode?

    init(for cell: GridCell) {
        self.cell = cell
        self.contents = cell.contents; self.sprite = cell.sprite; self.ownerName = cell.ownerName
    }

    func reschedule(_ stepper: Stepper) { cell?.reschedule(stepper) }
}

class HotKey: GridCellKey {
    var cell: GridCell?

    var contents: GridCell.Contents {
        get { return cell!.contents }
        set { cell!.contents = newValue }
    }

    var ownerName: String {
        get { return cell!.ownerName }
        set { cell!.ownerName = newValue }
    }

    var sprite: SKSpriteNode? {
        get { return cell!.sprite }
        set { cell!.sprite = newValue }
    }

    init(for cell: GridCell, ownerName: String) {
        precondition(cell.isLocked == false)
        self.cell = cell
        cell.isLocked = true
        cell.ownerName = ownerName
    }

    deinit { releaseLock() }

    func releaseLock() {
        Log.L.write("releaseLock: \(six(ownerName)) nil? \(cell == nil)", level: 48)
        cell?.releaseLock()
        reengageRequesters()
        cell = nil
    }
}

class NilKey: GridCellKey {
    //swiftlint:disable unused_setter_value
    var cell: GridCell? { get { nil } set { preconditionFailure() } }
    var contents: GridCell.Contents { get { .invalid } set { preconditionFailure() } }
    var ownerName: String { get { "invalid" } set { preconditionFailure() } }
    var sprite: SKSpriteNode?  { get { nil } set { preconditionFailure() } }
    //swiftlint:enable unused_setter_value
}
