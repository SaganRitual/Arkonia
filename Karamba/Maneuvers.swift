import Foundation
import SpriteKit

protocol ManeuverProtocol {
    var scene: SKScene { get }

    func execute(arkon: Karamba)
    func goSprite(arkon: Karamba, forceVector: CGVector)
    func selectActionPrimitive(arkon: Karamba, linearForceScale: CGFloat) -> SKAction
    func setMarker(arkon: Karamba, forceVector: CGVector)
}

protocol LinearManeuverProtocol: ManeuverProtocol {
    func calculateForceVector(sprite sprite_: SKNode) -> CGVector
}

protocol AngularManeuverProtocol: ManeuverProtocol {
    func calculateAngularForce(spriteSS: Int) -> CGFloat
}

extension ManeuverProtocol {

    func calculateForceVector(arkon: Karamba) -> CGVector {
        let r = CGFloat.random(in: 0..<1) * arkon.size.width / 2
        let θ = CGFloat.random(in: 0..<1) * CGFloat.tau
        return CGVector(radius: r, theta: θ)
    }

    func execute(arkon: Karamba) {
        let forceVector = calculateForceVector(arkon: arkon)

        setMarker(arkon: arkon, forceVector: forceVector)
        goSprite(arkon: arkon, forceVector: forceVector)
    }

    func goSprite(arkon: Karamba, forceVector: CGVector) {
        let primitive = selectActionPrimitive(arkon: arkon, linearForceScale: 5)
        arkon.run(primitive)
    }

    func selectActionPrimitive(arkon: Karamba, linearForceScale: CGFloat) -> SKAction {
        let primitives: [ActionPrimitive] = [.goFullStop, .goThrust(0), .goRotate(0), .goWait(0)]
        let motorOutputSS = Int(CGFloat.random(in: 0.0..<1.0) * CGFloat(primitives.count))

        switch primitives[motorOutputSS] {
        case .goFullStop:
            let action = SKAction.run {
                arkon.pBody.velocity = CGVector.zero
                arkon.pBody.angularVelocity = 0
            }

            return action

        case .goRotate:
            let a = CGFloat.random(in: -1.0..<1.0) / 5
            return SKAction.run { arkon.pBody.applyAngularImpulse(a) }

        case .goThrust:
            let vector = CGVector(
                radius: linearForceScale * arkon.size.width / 2, theta: arkon.zRotation
            )

            return SKAction.run { arkon.pBody.applyImpulse(vector) }

        case .goWait:
            let a = TimeInterval.random(in: 0.0..<1.0) * 3
            return SKAction.wait(forDuration: a)
        }
    }

    func setMarker(arkon: Karamba, forceVector: CGVector) {
        arkon.nose.zRotation = forceVector.theta - arkon.zRotation
        arkon.nose.position = CGPoint.zero
        arkon.nose.run(SKAction.fadeIn(withDuration: 0.1))
    }
}
