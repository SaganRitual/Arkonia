import SpriteKit

protocol GridletProtocol {
    var gridPosition: AKPoint { get }
    var scenePosition: CGPoint { get }
    var randomScenePosition: CGPoint? { get }
    var sprite: SKSpriteNode? { get }

    var contents: Gridlet.Contents { get }
    var previousContents: Gridlet.Contents { get }
    var gridletIsEngaged: Bool { get }
}

struct GridletCopy: GridletProtocol {
    let gridPosition: AKPoint
    let scenePosition: CGPoint
    let randomScenePosition: CGPoint?
    weak var sprite: SKSpriteNode?

    let contents: Gridlet.Contents
    let previousContents: Gridlet.Contents
    let gridletIsEngaged: Bool

    init(from original: GridletProtocol) {
        self.gridPosition = original.gridPosition
        self.scenePosition = original.scenePosition
        self.randomScenePosition = original.randomScenePosition
        self.contents = original.contents
        self.previousContents = original.previousContents
        self.gridletIsEngaged = original.gridletIsEngaged
        self.sprite = original.sprite
    }
}

class Gridlet: GridletProtocol {

    enum Contents: Double { case arkon, manna, nothing, unknown }

    let gridPosition: AKPoint
    let scenePosition: CGPoint
    var randomScenePosition: CGPoint?

    var contents = Contents.nothing { didSet { previousContents = oldValue } }
    var previousContents = Contents.nothing
    var gridletIsEngaged = false
    weak var sprite: SKSpriteNode?

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.gridPosition = gridPosition
        self.scenePosition = scenePosition
    }

    deinit {
        print("~Gridlet")
    }

    static func at(_ x: Int, _ y: Int) -> Gridlet {
        let p = AKPoint(x: x, y: y)
        guard let g = Grid.gridlets[p] else {
//            print(Grid.gridlets)
            print("whatchafuh", p)
            fatalError()
        }

        return g
    }

    static func at(_ position: AKPoint) -> Gridlet { return Gridlet.at(position.x, position.y) }

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

}

extension Gridlet {

    static func getRandomGridlet_() -> [Gridlet]? {
        var rg: Gridlet?

        repeat {
            rg = GriddleScene.arkonsPortal!.getRandomGridlet()
        } while rg!.contents != .nothing

        return [rg!]
    }

    typealias LockOnComplete = Sync.Lockable<Gridlet>.LockOnComplete

    static func getRandomGridlet(onComplete: LockOnComplete? = nil) {
        Grid.lock(getRandomGridlet_, onComplete, .concurrent)
    }

}
