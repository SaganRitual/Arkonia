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
        get {
            Log.L.write("arkon \(six(ownerName_)) owns (\(gridPosition.x), \(gridPosition.y))", select: 9)
            return ownerName_
        }
        set {
            Log.L.write("change owner of (\(gridPosition.x), \(gridPosition.y)) from \(six(ownerName_)) to \(six(newValue))", select: 9)
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
