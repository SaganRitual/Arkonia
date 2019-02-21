import Foundation
import SpriteKit

class MotorOutputs {
    weak var sprite: SKSpriteNode?
    let thrustPoints: [CGPoint]

    init(_ sprite: SKSpriteNode) {
        self.sprite = sprite

        self.thrustPoints = (0..<3).map {
            let r = sprite.frame.width / 2.0
            let theta = CGFloat($0) * 0.33

            return CGPoint(x: r * cos(theta), y: r * sin(theta))
        }
    }

    func getAction(_ thrustVectors: [CGVector]) -> SKAction {
        let jets: [SKAction] = zip(thrustPoints, thrustVectors).map {
            let duration = Double.random(in: 0.05..<0.15)

            return SKAction.applyImpulse($1, at: $0, duration: duration)
        }

        return SKAction.group(jets)
    }
}
