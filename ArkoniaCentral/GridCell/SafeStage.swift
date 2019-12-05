import SpriteKit

class SafeStage: GridConnectorProtocol {
    var consumedContents = GridCell.Contents.nothing
    var consumedSprite: SKSpriteNode?
    var didMove = false
    var fromCell: SafeCell?
    let toCell: SafeCell

    init(_ fromCell: SafeCell?, _ toCell: SafeCell) {
        self.fromCell = fromCell; self.toCell = toCell
        Log.L.write("SafeStage()", level: 28)
    }

    deinit {
        Log.L.write("~SafeStage()", level: 28)
    }

    func move() {
        Log.L.write("SafeStage().move", level: 28)

        // No fromCell means we didn't move
        guard let f = fromCell else { return }

        consumedContents = toCell.contents
        consumedSprite = toCell.sprite

        toCell.contents = f.contents
        toCell.sprite = f.sprite

        f.contents = .nothing
        f.sprite = nil

        didMove = true
    }
}
