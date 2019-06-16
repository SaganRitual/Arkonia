import SpriteKit

protocol ContactCoordinatorDelegate: class {
    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody])
}

protocol ContactDetectorProtocol {
    var contactResponder: ContactResponseProtocol? { get set }
    var isReadyForPhysics: Bool { get set }
    var senseResponder: SenseResponseProtocol? { get set }

    func pushContactedBodies(_ contactedBodies: [SKPhysicsBody])
    func pushSensedBodies(_ sensedBodies: [SKPhysicsBody])
}

extension ContactDetectorProtocol {
    var isReadyForPhysics: Bool {
        get { return false }

        // swiftlint:disable unused_setter_value
        // I think swiftlint should be smarter than this
        set { assert(false, "no default implementation") }
        // swiftlint:enable unused_setter_value
    }
}

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
    func transferEnergy(_ cJoules: CGFloat) -> EnergyPacketProtocol
}

protocol GeneProtocol {

}

struct GridPoint {
    let x: Int
    let y: Int
}

protocol HasContactDetector {
    var contactDetector: ContactDetectorProtocol? { get }
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
