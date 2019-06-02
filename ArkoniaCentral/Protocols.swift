import SpriteKit

protocol EnergySourceProtocol {
    func retrieveEnergy(_ cJoules: CGFloat) -> CGFloat
}

protocol GeneProtocol {

}

struct GridPoint {
    let x: Int
    let y: Int
}

enum LayerRole { case senseLayer, hiddenLayer, motorLayer }

protocol Massive: class {
    var mass: CGFloat { get set }
}

protocol NetDisplayGridProtocol {
    var layerRole: LayerRole { get set }

    func getPosition(_ gridPosition: GridPoint) -> CGPoint
    func setHorizontalSpacing(cNeurons: Int, padRadius: CGFloat)
}

protocol SpriteHangarProtocol {
    func makeSprite() -> SKSpriteNode
}
