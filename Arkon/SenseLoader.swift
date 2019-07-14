import Foundation
import SpriteKit

class SenseLoader {
    private static var portal: SKSpriteNode!

    var aVelocity: CGFloat!
    let portal: SKSpriteNode
    weak var arkon: Arkon!
    var vectorToOrigin: CGVector!
    var velocity: CGVector!
    var vectorToClosestArkon: CGVector?
    var vectorToClosestManna: CGVector?
    var zRotation: CGFloat = 0

    init(_ arkon: Arkon) {
        let sprite = arkon.sprite
        self.portal = SenseLoader.portal!

//        if Display.displayCycle != .actions { print("Here: displayCycle = ", Display.displayCycle) }
        let pBody = sprite.physicsBody!

        self.arkon = arkon

        aVelocity = sprite.normalizeAngleToTau(pBody.angularVelocity)
        zRotation = sprite.normalizeAngleToTau(sprite.zRotation)
        vectorToOrigin = sprite.normalizeVectorToEnvironment(sprite.position.asVector(), portal: portal)
//        print("v", sprite.position.asVector(), vectorToOrigin!)
        let uelocity = sprite.normalizeVectorToEnvironment(pBody.velocity, portal: portal)

        // Converting theta to tau scale gives me trouble, and I'm not sure it's
        // necessary anyway. Keep the original theta
        velocity = CGVector(radius: uelocity.radius, theta: pBody.velocity.theta)
//        print("v", pBody.velocity.theta, velocity.theta)

        vectorToClosestArkon = getVectorToClosestSensedArkon()
        vectorToClosestManna = getVectorToClosestSensedManna()
    }

    private func fullCapCheck(_ value: CGFloat) -> CGFloat {
        guard (value >= -1 && value <= 1) || value.isInfinite else {
            assert(false)
            return 0.0
        }

        return value
    }

    private func halfCapCheck(_ value: CGFloat) -> CGFloat {
        assert(value >= -0.001 && value <= 1)   // Goes slightly negative sometimes; rounding?
        return value
    }

    static func inject(_ portal: SKSpriteNode) {
        SenseLoader.portal = portal
    }

    func loadSenseData() -> [Double] {
        let foo = [Double](arrayLiteral:

            Double(aVelocity),
            Double(halfCapCheck(arkon.metabolism.oxygenLevel)),

            Double(velocity.magnitude),
            Double(velocity.theta),
//            Double(fullCapCheck(velocity.theta)),

            Double(fullCapCheck(vectorToOrigin.magnitude)),
            Double(fullCapCheck(vectorToOrigin.theta)),

            Double(halfCapCheck(countSensedManna() ?? 0)),
            Double(fullCapCheck(vectorToClosestManna?.magnitude ?? 1)),
            Double(fullCapCheck(vectorToClosestManna?.theta ?? 0)),

            Double(zRotation),
            Double(fullCapCheck(vectorToClosestArkon?.magnitude ?? 1)),
            Double(fullCapCheck(vectorToClosestArkon?.theta ?? 0))

        )

//        print("foo", foo)

        return foo
    }
}
