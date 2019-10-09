import SpriteKit

class Gridlet {
    private var semaphore = DispatchSemaphore(value: 1)

    let gridPosition: AKPoint
    let scenePosition: CGPoint

    private var contents_ = Contents.nothing
    var contents: Contents {
        get {
            semaphore.wait()
            defer { semaphore.signal() }
            return contents_
        }

        set {
            semaphore.wait()
            defer { semaphore.signal() }
            contents_ = newValue
        }
    }

    private var isEngaged_ = false
    var isEngaged: Bool {
        get {
            semaphore.wait()
            defer { semaphore.signal() }
            return isEngaged_
        }

        set {
            semaphore.wait()
            defer { semaphore.signal() }
            isEngaged_ = newValue
        }
    }

    private var sprite_: SKSpriteNode?
    var sprite: SKSpriteNode? {
        get {
            semaphore.wait()
            defer { semaphore.signal() }
            return sprite_
        }

        set {
            semaphore.wait()
            defer { semaphore.signal() }
            sprite_ = newValue
        }
    }

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
//        print("q", gridPosition)
        self.scenePosition = scenePosition
        self.gridPosition = gridPosition
    }

    static func at(_ x: Int, _ y: Int) -> Gridlet {
        let p = AKPoint(x: x, y: y)
        guard let g = Griddle.gridlets[p] else {
            print(Griddle.gridlets)
            fatalError()
        }
//        print("p", p, g.gridPosition)

        return g
    }

    static func at(_ position: AKPoint) -> Gridlet { return Gridlet.at(position.x, position.y) }

    static func constrainToGrid(_ x: Int, _ y: Int) -> (Int, Int) {
        let cx = Griddle.dimensions.wGrid - 1
        let cy = Griddle.dimensions.hGrid - 1

        let constrainedX = min(cx - 1, max(-cx + 1, x))
        let constrainedY = min(cy - 1, max(-cy + 1, y))

//        print("cg", x, constrainedX, y, constrainedY)

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
