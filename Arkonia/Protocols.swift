import SpriteKit

protocol EnergyPacketProtocol {
    var energyContent: CGFloat { get }
    var mass: CGFloat { get }
}

extension EnergyPacketProtocol {
    var energyContent: CGFloat { return 0 }
    var mass: CGFloat { return 0 }
}

protocol EnergySourceProtocol {
    func withdrawFromReady(_ cJoules: CGFloat) -> CGFloat
    func withdrawFromSpawn(_ cJoules: CGFloat) -> CGFloat
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

typealias FactoryFunction = (SKTexture) -> SKSpriteNode
