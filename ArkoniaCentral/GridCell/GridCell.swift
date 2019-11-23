import SpriteKit

class GridCell: GridCellProtocol, Equatable {
    enum Contents: Double, CaseIterable {
        case arkon, invalid, manna, nothing

        func isEdible() -> Bool {
            return self == .arkon || self == .manna
        }

        func isOccupied() -> Bool {
            return self == .arkon || self == .manna
        }
    }

    let gridPosition: AKPoint
    var randomScenePosition: CGPoint?
    let scenePosition: CGPoint

    var contents = Contents.nothing { didSet { previousContents = oldValue } }
    private(set) var previousContents = Contents.nothing
    private var ownerName_: String?
    var ownerName: String? {
        get { return ownerName_ }
        set {
            Log.L.write("here: \(six(newValue))", select: 4)
            ownerName_ = newValue
        }
    }
    weak var sprite: SKSpriteNode?

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.gridPosition = gridPosition
        self.scenePosition = scenePosition
    }

    deinit {
//        Log.L.write("~GridCell at \(gridPosition), owner \(owner ?? "no owner")")
    }
}
