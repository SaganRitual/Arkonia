import SpriteKit

struct GridPoint {
    let x: Int
    let y: Int
}

enum LayerRole { case senseLayer, hiddenLayer, motorLayer }

protocol NetDisplayGridProtocol {
    var layerRole: LayerRole { get set }

    func getPosition(_ gridPosition: GridPoint) -> CGPoint
    func setHorizontalSpacing(cNeurons: Int, padRadius: CGFloat)
}

protocol SpriteHangarProtocol {
    func makeSprite() -> SKSpriteNode
}