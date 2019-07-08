import Foundation
import SpriteKit

extension SKSpriteNode {
    static var portalExtendedRadius: CGFloat = 0

    func normalizeAngleToTau(_ angle: CGFloat) -> CGFloat {
        if angle == 0 || angle.isInfinite { return 0 }
        let sign = abs(angle) / angle

        let chopped = abs(angle).truncatingRemainder(dividingBy: CGFloat.tau) / CGFloat.tau
        let scaled = chopped / CGFloat.pi
        return scaled * sign
    }

    func normalizeVectorToEnvironment(_ vector: CGVector, portal: SKSpriteNode) -> CGVector {
        if vector == CGVector.zero { return CGVector(radius: 1.0, theta: 0) /*CGVector.zero*/ }
        let portalExtendedRadius: CGFloat = portal.size.hypotenuse / 2.0
        let scaleFactor = Arkon.scaleFactor * Arkon.scaleFactor
        let normalizedR = 1.0 - abs(2 * vector.magnitude / portalExtendedRadius * scaleFactor)
        let normalizedΘ = normalizeAngleToTau(vector.theta)
//        print("nr", vector.magnitude, normalizedR, vector.theta, normalizedΘ)
        return CGVector(radius: normalizedR, theta: normalizedΘ)
    }
}

extension SenseLoader {

    enum Subset: String { case arkon, manna }

    func countSensedArkons() -> CGFloat? { return countSensedBodies(.arkon) }

    func countSensedBodies(_ subset: Subset) -> CGFloat? {
        guard let bodies = getBodies(subset, from: arkon.contactDetector?.sensedBodies)
            else { return nil }

        if bodies.isEmpty { return nil }
        return 1.0 / CGFloat(bodies.count)
    }

    func countSensedManna() -> CGFloat? { return countSensedBodies(.manna) }

    func getBodies(_ subset: Subset, from fullSet: [SKPhysicsBody]?)
        -> [SKPhysicsBody]? {

            guard let fs = fullSet else { return nil }

            let result = fs.filter {
                guard let node = $0.node else { return false }
                guard let name = node.name else { return false }
                return name.starts(with: subset.rawValue)
            }

            return result.isEmpty ? nil : result
    }

    func getContactedArkons() -> [SKPhysicsBody]? {
        return getBodies(.arkon, from: arkon.contactDetector?.contactedBodies)
    }

    func getContactedManna() -> [SKPhysicsBody]? {
        return getBodies(.manna, from: arkon.contactDetector?.contactedBodies)
    }

    func getSensedArkons() -> [SKPhysicsBody]? {
        return getBodies(.arkon, from: arkon.contactDetector?.sensedBodies)
    }

    func getSensedManna() -> [SKPhysicsBody]? {
        return getBodies(.manna, from: arkon.contactDetector?.sensedBodies)
    }

    func getVectorToClosestSensedArkon() -> CGVector? {
        return getVectorToClosestSensedBody(.arkon)
    }

    func getVectorToClosestSensedBody(_ subset: Subset) -> CGVector? {
        guard var sensed = (subset == .arkon) ?
            getSensedArkons() : getSensedManna() else { return nil }

        let contacted = (subset == .arkon) ? getContactedArkons() : getContactedManna()

        if sensed.isEmpty {
            sensed = sensed.compactMap {
                guard let touched = contacted else { return nil }
                return touched.contains($0) ? nil : $0
            }
        }

        if sensed.isEmpty { return nil }
        let closest = sensed.min {
            guard let lhsNode = $0.node, let rhsNode = $1.node else { preconditionFailure() }
            if lhsNode.position == rhsNode.position { return Bool.random() }
            return arkon.sprite.position.distance(to: lhsNode.position) <
                   arkon.sprite.position.distance(to: rhsNode.position)
        }

        guard let closestNode = closest?.node else { preconditionFailure() }
        let fromMeToHim = arkon.sprite.position.makeVector(to: closestNode.position)
        let raw = CGVector(radius: fromMeToHim.radius, theta: fromMeToHim.theta)

        return arkon.sprite.normalizeVectorToEnvironment(raw, portal: portal)
    }

    func getVectorToClosestSensedManna() -> CGVector? {
        return getVectorToClosestSensedBody(.manna)
    }

}
