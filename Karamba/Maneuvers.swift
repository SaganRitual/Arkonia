import Foundation
import SpriteKit

enum ActionPrimitive: Comparable, Hashable {
    case goFullStop
    case goRotate(CGFloat)
    case goThrust(CGFloat)
    case goWait

    static func < (_ lhs: ActionPrimitive, _ rhs: ActionPrimitive) -> Bool {
        switch (lhs, rhs) {
        case (.goWait, _): return false

        case (_, .goFullStop): return false
        case (.goFullStop, _): return true

        case (.goThrust, .goWait): return true
        case (.goThrust, _): return false

        case (.goRotate, .goWait): return true
        case (.goRotate, .goThrust): return true
        case (.goRotate, _): return false
        }
    }
}

protocol ManeuverProtocol {
    var scene: SKScene { get }

    func execute(arkon: Karamba, motorOutputs: [Double])
    func goSprite(arkon: Karamba, motorOutputs: [Double])
    func selectActionPrimitive(arkon: Karamba, motorOutputs: [Double]) -> SKAction
}

protocol LinearManeuverProtocol: ManeuverProtocol {
    func calculateForceVector(sprite sprite_: SKNode) -> CGVector
}

protocol AngularManeuverProtocol: ManeuverProtocol {
    func calculateAngularForce(spriteSS: Int) -> CGFloat
}

extension ManeuverProtocol {

    func execute(arkon: Karamba, motorOutputs: [Double]) {
        goSprite(arkon: arkon, motorOutputs: motorOutputs)
    }

    func goSprite(arkon: Karamba, motorOutputs: [Double]) {
        let primitive = selectActionPrimitive(arkon: arkon, motorOutputs: motorOutputs)
        arkon.run(primitive)
    }

    func selectActionPrimitive(arkon: Karamba, motorOutputs: [Double]) -> SKAction {

        var m = motorOutputs
        let power = CGFloat(m.removeFirst())
        let primitives: [ActionPrimitive] = [.goFullStop, .goThrust(power), .goRotate(power), .goWait]
        let tagged: [ActionPrimitive: Double] = zip(primitives, motorOutputs).reduce([:]) {
            var dictionary = $0
            dictionary[$1.0] = $1.1
            return dictionary
        }

        let sorted = tagged.sorted { lhs, rhs in lhs.value < rhs.value }
        let maxEntry = hardBind(sorted.last)

        switch maxEntry.key {
        case .goFullStop:
            let action = SKAction.run {
                arkon.pBody.velocity = CGVector.zero
                arkon.pBody.angularVelocity = 0
            }

            return action

        case let .goRotate(power):
            return SKAction.run { arkon.pBody.applyAngularImpulse(power) }

        case let .goThrust(power):
            let vector = CGVector(radius: power, theta: arkon.zRotation)
            return SKAction.run { arkon.pBody.applyImpulse(vector) }

        case .goWait:
            return SKAction.wait(forDuration: 1.0 / 60.0)
        }
    }
}
