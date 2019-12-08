import SpriteKit

class CellTaxi {
    var consumedContents = GridCell.Contents.nothing
    weak var consumedSprite: SKSpriteNode?
    var didMove = false
    var fromCell: HotKey?
    var toCell: HotKey?

    init(_ fromCell: HotKey?, _ toCell: HotKey) {
        self.fromCell = fromCell; self.toCell = toCell
    }

    deinit {
        Log.L.write("~CellTaxi from  \(six(toCell?.cell.ownerName)) to \(six(toCell?.cell.ownerName))", level: 40)
    }

    func move() {
        consumedContents = .nothing
        consumedSprite = nil

        // No fromCell means we didn't move
        guard let f = fromCell else { return }
        guard let t = toCell else { preconditionFailure() }

        Log.L.write("Taxiing from \(f) to \(t), consuming \(t.contents)", level: 31)

        consumedContents = t.contents
        consumedSprite = t.sprite

        t.contents = f.contents
        t.sprite = f.sprite

        f.contents = .nothing
        f.sprite = nil

        didMove = true
    }
}
