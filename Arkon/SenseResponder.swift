import SpriteKit

struct SenseResponder: SenseResponseProtocol {
    func respond(_ sensedBodies: [SKPhysicsBody]) {
        //            sensedBodies.forEach { ($0.node as? SKSpriteNode)?.color = .yellow }
    }
}
