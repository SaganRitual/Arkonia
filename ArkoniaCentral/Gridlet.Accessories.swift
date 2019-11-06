import SpriteKit

protocol GridletProtocol {
    var gridPosition: AKPoint { get }
    var scenePosition: CGPoint { get }
    var randomScenePosition: CGPoint? { get }
    var sprite: SKSpriteNode? { get }

    var contents: Gridlet.Contents { get }
    var gridletOwner: String? { get }
}

struct GridletCopy: GridletProtocol {
    let gridPosition: AKPoint
    let scenePosition: CGPoint
    let randomScenePosition: CGPoint?
    weak var sprite: SKSpriteNode?

    let contents: Gridlet.Contents
    let gridletOwner: String?

    init(from original: GridletProtocol, runType: Dispatch.RunType) {
        assert(runType == .barrier)
        self.gridPosition = original.gridPosition
        self.scenePosition = original.scenePosition
        self.randomScenePosition = original.randomScenePosition
        self.contents = original.contents
        self.gridletOwner = original.gridletOwner
        self.sprite = original.sprite
    }
}

extension Gridlet {
    static func atIf(_ x: Int, _ y: Int) -> Gridlet? {
        let p = AKPoint(x: x, y: y)
        guard let g = Grid.gridlets[p] else { return nil }
        return g
    }

    static func at(_ x: Int, _ y: Int) -> Gridlet {
        let p = AKPoint(x: x, y: y)
        guard let g = Grid.gridlets[p] else {
//            print(Grid.gridlets)
//            print("whatchafuh", p)
            fatalError()
        }

        return g
    }

    static func atIf(_ position: AKPoint) -> Gridlet? {
        return Gridlet.atIf(position.x, position.y)
    }

    static func at(_ position: AKPoint) -> Gridlet {
        return Gridlet.at(position.x, position.y)
    }

    static func atIf(_ copy: GridletCopy) -> Gridlet? {
        return atIf(copy.gridPosition)
    }

    static func constrainToGrid(_ x: Int, _ y: Int) -> (Int, Int) {
        let cx = Grid.dimensions.wGrid - 1
        let cy = Grid.dimensions.hGrid - 1

        let constrainedX = min(cx, max(-cx, x))
        let constrainedY = min(cy, max(-cy, y))

        return (constrainedX, constrainedY)
    }

    static func isOnGrid(_ x: Int, _ y: Int) -> Bool {
        let (cx, cy) = constrainToGrid(x, y)
        return cx == x && cy == y
    }

    static func + (_ lhs: Gridlet, _ rhs: Gridlet) -> Gridlet {
        return Gridlet.at(lhs.gridPosition + rhs.gridPosition)
    }

    static func + (_ lhs: Gridlet, _ rhs: AKPoint) -> Gridlet {
        return Gridlet.at(lhs.gridPosition + rhs)
    }

    static func - (_ lhs: Gridlet, _ rhs: AKPoint) -> Gridlet {
        return Gridlet.at(lhs.gridPosition - rhs)
    }

    static func == (_ lhs: Gridlet, _ rhs: Gridlet) -> Bool {
        return lhs === rhs
    }

    static func == (_ lhs: Gridlet, _ rhs: GridletCopy) -> Bool {
        guard let r = Gridlet.atIf(rhs) else { fatalError() }
        return lhs === r
    }

}
