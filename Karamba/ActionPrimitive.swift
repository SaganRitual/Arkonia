import Foundation
import SpriteKit

enum ActionPrimitive {
    case goThrust(CGFloat)
    case goRotate(CGFloat)
    case goFullStop
    case goWait

    //
    // 4 kilocalories per gram of body mass
    // 4 kilocalories =ish 16750 newton meters
    //
    // SKPhysics impulses are in Newton-seconds
    // - impulse magnitude n 1 Newton / 60fps
    //
    // 1 Newton = force required to accelerate 1kg at 1m/s^2
    //
    // With all that technical stuff said, I'm just going to
    // divide the impulse by 60 and call that one Newton.
    // Then / 16750 to get grams of body mass. (Yeah, right,
    // I'll just make up a fudge factor.)
    //
    static func getMotionActions(sprite: SKSpriteNode, motorOutputs: [Double]) -> SKAction {

        let fudgeFactor: CGFloat = 100.0
        let angularPower = abs(CGFloat(motorOutputs[0])) / (5000 * fudgeFactor)
        let linearPower = abs(CGFloat(motorOutputs[1])) / fudgeFactor

        let angularDamping = abs(CGFloat(motorOutputs[2])) * 2// / (5000 * fudgeFactor)
        let linearDamping = abs(CGFloat(motorOutputs[3])) * 2// / fudgeFactor

        let lostMass = (angularPower + linearPower) / 60.0
        sprite.physicsBody!.mass -= lostMass
        sprite.arkon?.hunger += lostMass

        let rotate = SKAction.run {
            sprite.physicsBody!.angularDamping = angularDamping
            sprite.physicsBody!.applyAngularImpulse(angularPower)
        }

        let thrustVector = CGVector.polar(radius: linearPower, theta: sprite.zRotation)
        let thrust = SKAction.run {
            sprite.physicsBody!.linearDamping = linearDamping
            sprite.physicsBody!.applyImpulse(thrustVector)
        }

        let group = SKAction.group([rotate, thrust])
        return group
    }
}
