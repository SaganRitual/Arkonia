import Foundation
import SpriteKit

enum Actions {
    static func aApplyAngularImpulse(nS: CGFloat, asThoughFor duration: TimeInterval) -> SKAction {
        let scaled = nS * ArkonFactory.scale
        return SKAction.applyAngularImpulse(scaled, duration: duration)
    }

    static func aApplyForce(nM: CGVector, asThoughFor duration: TimeInterval) -> SKAction {
        let scaled = nM * ArkonFactory.scale
        return SKAction.applyForce(scaled, duration: duration)
    }

    static func aApplyImpulse(nS: CGVector, asThoughFor duration: TimeInterval) -> SKAction {
        let scaled = nS * ArkonFactory.scale
        return SKAction.applyImpulse(scaled, duration: duration)
    }

    static func aApplyTorque(nM: CGFloat, duration: TimeInterval) -> SKAction {
        let scaled = nM * ArkonFactory.scale
        return SKAction.applyTorque(scaled, duration: 1)
    }

    static func aPhysicsAction(node: SKNode, action: SKAction, key: String) -> SKAction {
        let named = SKAction.run { node.run(action, withKey: key)  }
        return named
    }

    static func aPhysicsActionWithCancel(
        node: SKNode,
        action: SKAction,
        refractory: TimeInterval,
        key: String
        ) -> SKAction {
        let physicsAction = aPhysicsAction(node: node, action: action, key: key)
        let waitCancel = aWaitCancel(node: node, seconds: refractory, key: key)
        let alpha = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
        let beta = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
        let group = SKAction.group([physicsAction, waitCancel])
        let alphized = SKAction.sequence([alpha, group, beta])
        return alphized
    }

    static func aWait(seconds: TimeInterval) -> SKAction {
        return SKAction.wait(forDuration: seconds)
    }

    static func aWaitCancel(node: SKNode, seconds: TimeInterval, key: String) -> SKAction {
        let wait = aWait(seconds: seconds)
        let cancel = SKAction.run { node.removeAction(forKey: key) }
        let sequence = SKAction.sequence([wait, cancel])
        return sequence
    }
}
