import SpriteKit

class CellShuttle {
    var consumedContents = GridCell.Contents.nothing
    weak var consumedSprite: SKSpriteNode?
    var didMove = false
    var fromCell: HotKey?
    var toCell: HotKey?

    init(_ fromCell: HotKey?, _ toCell: HotKey) {
        self.fromCell = fromCell; self.toCell = toCell
    }

    func move(_ onComplete: @escaping () -> Void) {
        consumedContents = .nothing
        consumedSprite = nil

        // No fromCell means we didn't move
        guard let f = fromCell?.bell else { return }
        guard let t = toCell?.bell else { preconditionFailure() }

        consumedContents = t.contents
        consumedSprite = t.sprite

        func a() { t.setContents(to: f.contents, newSprite: f.sprite, b) }
        func b() { f.setContents(to: .nothing, newSprite: nil, c) }
        func c() { self.didMove = true; onComplete() }

        a()
    }

    func transferKeys(to winner: Stepper, _ onComplete: @escaping (CellShuttle) -> Void) {
        toCell?.transferKey(to: winner) { onComplete(self) }
    }
}
