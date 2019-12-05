import SpriteKit

protocol GridConnectorProtocol { }

class SafeCell: GridCellProtocol, GridConnectorProtocol {
    var contents: GridCell.Contents
    weak var hotCell: GridCell?
    let gridPosition: AKPoint
    let scenePosition: CGPoint
    let randomScenePosition: CGPoint?
    weak var sprite: SKSpriteNode?

    var isHot: Bool { hotCell != nil }

    init(from hotCell: GridCell, takeOwnership: Bool = true) {
        if takeOwnership { self.hotCell = hotCell }

        self.gridPosition = hotCell.gridPosition
        self.scenePosition = hotCell.scenePosition
        self.randomScenePosition = hotCell.randomScenePosition
        self.contents = hotCell.contents
        self.sprite = hotCell.sprite
    }

    deinit {
        Log.L.write("~SafeCell", level: 27)
        hotCell?.releaseLock(self)
    }
}
