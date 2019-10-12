import SpriteKit

class Gridlet {
    let gridPosition: AKPoint
    let scenePosition: CGPoint

    var contents = Contents.nothing
    var gridletIsEngaged = false
    var sprite: SKSpriteNode?

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.scenePosition = scenePosition
        self.gridPosition = gridPosition
    }

    static func at(_ x: Int, _ y: Int) -> Gridlet {
        let p = AKPoint(x: x, y: y)
        guard let g = Grid.gridlets[p] else {
            print(Grid.gridlets)
            fatalError()
        }

        return g
    }

    static func at(_ position: AKPoint) -> Gridlet { return Gridlet.at(position.x, position.y) }

    static func constrainToGrid(_ x: Int, _ y: Int) -> (Int, Int) {
        let cx = Grid.dimensions.wGrid - 1
        let cy = Grid.dimensions.hGrid - 1

        let constrainedX = min(cx - 1, max(-cx + 1, x))
        let constrainedY = min(cy - 1, max(-cy + 1, y))

        return (constrainedX, constrainedY)
    }

    static func isOnGrid(_ x: Int, _ y: Int) -> Bool {
        let (cx, cy) = constrainToGrid(x, y)
        return cx == x && cy == y
    }

}

extension Gridlet {

    enum Contents: Double {
        case arkon, manna, nothing
    }

}
