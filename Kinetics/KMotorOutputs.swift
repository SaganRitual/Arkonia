import Foundation
import SpriteKit

class MotorOutputs {
    weak var sprite: SKSpriteNode?
    let thrustPoints: [CGPoint]

    init(_ sprite: SKSpriteNode) {
        self.sprite = sprite
        let r = sprite.frame.width / 2

        self.thrustPoints = (0..<2).map {
            let theta = (2.0 * 3.14159 / 2.0) * CGFloat($0)
            let p = CGPoint(x: r * cos(theta), y: r * sin(theta))
            return sprite.convert(p, to: sprite.scene!)
        }

//        self.thrustPoints = [sprite.convert(CGPoint.zero, to: sprite.scene!)]
    }

    func getAction(_ thrustVectors: [CGVector]) -> SKAction {
        let aJets: [SKAction] = zip(thrustPoints, thrustVectors).map {
            return SKAction.applyForce($1, at: $0, duration: 0.20)
        }

//        let aJets = [SKAction.applyForce(thrustVectors[0], duration: 0.20)]
        let gJets = SKAction.group(aJets)
        let wait = SKAction.wait(forDuration: 0.05)

        let body = sprite!.physicsBody!
        let stop = SKAction.run { body.velocity = CGVector.zero }
        return SKAction.sequence([gJets, stop, wait])
    }
}
