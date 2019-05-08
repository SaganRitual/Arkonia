import SpriteKit

struct GridPoint {
    let x: Int
    let y: Int
}

enum LayerRole { case senseLayer, hiddenLayer, motorLayer }

protocol NetDisplayGridProtocol {
        func getPosition(_ gridPosition: GridPoint) -> CGPoint
}

protocol SpriteHangarProtocol {
    func makeSprite() -> SKSpriteNode
}
