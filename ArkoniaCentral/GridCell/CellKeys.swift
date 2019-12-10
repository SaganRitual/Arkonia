import SpriteKit

protocol GridCellKey: class {
    var contents: GridCell.Contents { get }
    var ownerName: String { get }
    var sprite: SKSpriteNode? { get }
}

class ColdKey: GridCellKey {
    internal let contents: GridCell.Contents
    internal let ownerName: String
    internal weak var sprite: SKSpriteNode?
    internal let debugDontUseIsLocked: Bool

    init(for cell: GridCell) {
        self.contents = cell.contents; self.sprite = cell.sprite; self.ownerName = cell.ownerName
        self.debugDontUseIsLocked = cell.isLocked
    }
}

class HotKey: GridCellKey {
    let cell: GridCell

    var contents: GridCell.Contents {
        get { return cell.contents }
        set { cell.contents = newValue }
    }

    var ownerName: String {
        get { return cell.ownerName }
        set { cell.ownerName = newValue }
    }

    var sprite: SKSpriteNode? {
        get { return cell.sprite }
        set { cell.sprite = newValue }
    }

    init(for cell: GridCell) {
        precondition(cell.isLocked == false)
        self.cell = cell
        Log.L.write("HotKey at \(cell.gridPosition) for \(six(cell.ownerName))", level: 44)
    }

    deinit {
        let sp = sprite == nil
        let gs = sprite?.getStepper(require: false) == nil
        let mn = sprite?.name == nil
        Log.L.write("~HotKey at \(cell.gridPosition) \(sp) \(gs) \(six(cell.ownerName)) \(mn)  \(six(sprite?.getStepper(require: false)?.name))", level: 44)
        precondition(cell.isLocked)
        cell.releaseLock()
        precondition(cell.isLocked == false)
    }
}

class NilKey: GridCellKey {
    //swiftlint:disable unused_setter_value
    var contents: GridCell.Contents { get { .invalid } set { preconditionFailure() } }
    var ownerName: String { get { "invalid" } set { preconditionFailure() } }
    var sprite: SKSpriteNode?  { get { nil } set { preconditionFailure() } }
    //swiftlint:enable unused_setter_value
}
