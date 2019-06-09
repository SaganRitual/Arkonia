import SpriteKit

protocol ContactResponseProtocol {
    func respond(_ contactedBodies: [SKPhysicsBody])
}

protocol EnergyPacketProtocol {
    var energyContent: CGFloat { get }
    var mass: CGFloat { get }
}

extension EnergyPacketProtocol {
    var energyContent: CGFloat { return 0 }
    var mass: CGFloat { return 0 }
}

protocol EnergySourceProtocol {
    func expendEnergy(_ packet: EnergyPacketProtocol) -> CGFloat
    func retrieveEnergy(_ cJoules: CGFloat) -> EnergyPacketProtocol
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

typealias FactoryFunction = (SKTexture) -> SKSpriteNode

protocol SenseResponseProtocol {
    func respond(_ contactedBodies: [SKPhysicsBody])
}

protocol SpriteHangarProtocol {
    func makeSprite() -> SKSpriteNode
}
