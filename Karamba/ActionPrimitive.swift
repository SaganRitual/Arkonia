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

        let angularPower = CGFloat(motorOutputs[0]) / 50000
        let linearPower = CGFloat(motorOutputs[1])

//        let angularDamping = abs(CGFloat(motorOutputs[2]))
//        let linearDamping = abs(CGFloat(motorOutputs[3]))

        let lostMassFromNetSignal = nok(sprite.arkon).signalDriver.kNet.getNetSignalCost()
        let lostMassFromMotorOutputs = (angularPower + linearPower) / 60.0

        let lostMass = lostMassFromMotorOutputs + lostMassFromNetSignal

        let pBody = hardBind(sprite.physicsBody)
        let arkon = hardBind(sprite.arkon)

        pBody.mass -= lostMass
        arkon.hunger += lostMass

        let rotate = SKAction.run {
            pBody.angularDamping = 1.0//angularDamping
            pBody.applyAngularImpulse(angularPower)
        }

        if pBody.velocity.magnitude > 7.5 {
            sprite.color = .purple
            print("\(arkon.fishNumber) accelerating", pBody.velocity.magnitude)
        }

        let thrustVector = CGVector.polar(radius: linearPower, theta: sprite.zRotation)
        let thrust = SKAction.run {
            pBody.linearDamping = 1.0//linearDamping
            pBody.applyImpulse(thrustVector)
        }

        let group = SKAction.group([rotate, thrust])
        return group
    }
}
