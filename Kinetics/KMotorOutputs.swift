import Foundation
import SpriteKit

class MotorOutputs {
    weak var sprite: SKSpriteNode?
    let thrustPoints: [CGPoint]

    init(_ sprite: SKSpriteNode) {
        self.sprite = sprite
        let r = sprite.frame.width / 2

        self.thrustPoints = (0..<3).map {
            let theta = (2.0 * 3.14159 / 3) * CGFloat($0)

            return CGPoint(x: r * cos(theta), y: r * sin(theta))
        }
    }

    func getAction(_ thrustVectors: [CGVector]) -> SKAction {
        let jets: [SKAction] = zip(thrustPoints, thrustVectors).map {
            let interval = SKAction.wait(forDuration: 0.25)
            let impulse = SKAction.applyImpulse($1, at: $0, duration: 0.01)
            return SKAction.sequence([impulse, interval])
        }

        return SKAction.group(jets)
    }
}
