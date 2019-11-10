import SpriteKit

protocol GridletProtocol {
    var gridPosition: AKPoint { get }
    var scenePosition: CGPoint { get }
    var randomScenePosition: CGPoint? { get }
    var sprite: SKSpriteNode? { get }

    var contents: Gridlet.Contents { get }
    var owner: String? { get }
}

struct GridletCopy: GridletProtocol {
    let gridPosition: AKPoint
    let scenePosition: CGPoint
    let randomScenePosition: CGPoint?
    weak var sprite: SKSpriteNode?

    let contents: Gridlet.Contents
    let owner: String?

    init(from original: GridletProtocol) {
        self.gridPosition = original.gridPosition
        self.scenePosition = original.scenePosition
        self.randomScenePosition = original.randomScenePosition
        self.contents = original.contents
        self.owner = original.owner
        self.sprite = original.sprite
    }
}

class Gridlet: GridletProtocol, Equatable {

    enum Contents: Double { case arkon, manna, nothing }

    let gridPosition: AKPoint
    let scenePosition: CGPoint
    var randomScenePosition: CGPoint?

    var contents = Contents.nothing { didSet { previousContents = oldValue } }
    private(set) var previousContents = Contents.nothing
    var owner: String?
    weak var sprite: SKSpriteNode?

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.gridPosition = gridPosition
        self.scenePosition = scenePosition
    }

    deinit {
        print("~Gridlet at \(gridPosition), owner \(owner ?? "no owner")")
    }

    func isEngaged_(by thisGuy: String) -> Bool { return thisGuy == self.owner }

    func isEngaged(by thisGuy: String) -> Bool {
        return Grid.shared.serialQueue.sync { isEngaged_(by: thisGuy) }
    }
}
