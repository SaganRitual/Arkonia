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

    init(_ arkon: Arkon) {
        let sprite = arkon.sprite
        self.portal = SenseLoader.portal!

//        if Display.displayCycle != .actions { print("Here: displayCycle = ", Display.displayCycle) }
        let pBody = sprite.physicsBody!

        self.arkon = arkon

        aVelocity = sprite.normalizeAngleToTau(pBody.angularVelocity)
        vectorToOrigin = sprite.normalizeVectorToEnvironment(sprite.position.asVector(), portal: portal)
        velocity = sprite.normalizeVectorToEnvironment(pBody.velocity, portal: portal)

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
        assert(value >= 0 && value <= 1)
        return value
    }

    static func inject(_ portal: SKSpriteNode) {
        SenseLoader.portal = portal
    }

    func loadSenseData() -> [Double] {
        return [Double](arrayLiteral:

            Double(fullCapCheck(aVelocity)),
            Double(halfCapCheck(arkon.metabolism.oxygenLevel)),

            Double(fullCapCheck(min(velocity.magnitude, 0))),
            Double(fullCapCheck(velocity.theta)),

            Double(fullCapCheck(vectorToOrigin.magnitude)),
            Double(fullCapCheck(vectorToOrigin.theta)),

            Double(halfCapCheck(countSensedManna() ?? 0)),
            Double(fullCapCheck(vectorToClosestManna?.magnitude ?? 1)),
            Double(fullCapCheck(vectorToClosestManna?.theta ?? 0)),

            Double(arkon.sprite.zRotation),
            Double(fullCapCheck(vectorToClosestArkon?.magnitude ?? 1)),
            Double(fullCapCheck(vectorToClosestArkon?.theta ?? 0))

        )
    }
}
