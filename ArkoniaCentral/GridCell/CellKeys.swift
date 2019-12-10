import SpriteKit

protocol GridCellKey: class {
    var contents: GridCell.Contents { get set }
    var sprite: SKSpriteNode? { get set }
}

class ColdKey: GridCellKey {
    //swiftlint:disable unused_setter_value
    private let contents_: GridCell.Contents
    var contents: GridCell.Contents { get { contents_ } set { preconditionFailure() } }

    private let sprite_: SKSpriteNode?
    var sprite: SKSpriteNode?  { get { sprite_ } set { preconditionFailure() } }
    //swiftlint:enable unused_setter_value

    init(for cell: GridCell) {
        self.contents_ = cell.contents; self.sprite_ = cell.sprite
    }
}

class HotKey: GridCellKey {
    let cell: GridCell

    var contents: GridCell.Contents {
        get { return cell.contents }
        set { cell.contents = newValue }
    }

    var sprite: SKSpriteNode? {
        get { return cell.sprite }
        set { cell.sprite = newValue }
    }

    init(for cell: GridCell) {
        self.cell = cell
        Log.L.write("HotKey \(six(sprite?.getStepper(require: false)?.name))", level: 31)
    }

    deinit {
        cell.releaseLock()
        Log.L.write("~HotKey \(six(sprite?.getStepper(require: false)?.name))", level: 31)
    }
}

class NilKey: GridCellKey {
    //swiftlint:disable unused_setter_value
    var contents: GridCell.Contents { get { .invalid } set { preconditionFailure() } }
    var sprite: SKSpriteNode?  { get { nil } set { preconditionFailure() } }
    //swiftlint:enable unused_setter_value
}
