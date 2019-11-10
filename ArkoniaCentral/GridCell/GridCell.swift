import SpriteKit

class GridCell: GridCellProtocol, Equatable {
    enum Contents: Double { case arkon, manna, nothing }

    let gridPosition: AKPoint
    var randomScenePosition: CGPoint?
    let scenePosition: CGPoint

    var contents = Contents.nothing { didSet { previousContents = oldValue } }
    private(set) var previousContents = Contents.nothing
    var safeConnector: SafeConnectorProtocol?
    var owner: String?
    weak var sprite: SKSpriteNode?

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.gridPosition = gridPosition
        self.scenePosition = scenePosition
    }

    deinit {
        print("~Gridlet at \(gridPosition), owner \(owner ?? "no owner")")
    }
}

extension GridCell {
    static func getRandomGridlet_() -> GridCell {
        var rg: GridCell!

        repeat {
            rg = GriddleScene.arkonsPortal!.getRandomGridlet()
        } while rg.contents != .nothing

        return rg
    }

    static func getRandomGridlet(onComplete: (GridCell) -> Void) {
        let g = getRandomGridlet_()
        onComplete(g)
    }
}
