import Foundation
import SpriteKit

class SenseLoader {
    let aVelocity: CGFloat
    let portal = PortalServer.shared.arkonsPortal
    weak var sprite: Karamba!
    let vectorToOrigin: CGVector
    let velocity: CGVector
    var vectorToClosestArkon: CGVector?
    var vectorToClosestManna: CGVector?

    init(_ sprite: Karamba) {
        if Display.displayCycle != .actions { print("Here: displayCycle = ", Display.displayCycle) }
        let pBody = hardBind(sprite.physicsBody)

        self.sprite = sprite

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

    func loadSenseData() {
        sprite.sensoryInputs.removeAll(keepingCapacity: true)

        sprite.sensoryInputs.append(contentsOf: [Double](arrayLiteral:

            Double(fullCapCheck(aVelocity)),
            Double(halfCapCheck(sprite.metabolism.oxygenLevel)),

            Double(fullCapCheck(velocity.magnitude)),
            Double(fullCapCheck(velocity.theta)),

            Double(fullCapCheck(vectorToOrigin.magnitude)),
            Double(fullCapCheck(vectorToOrigin.theta)),

            Double(halfCapCheck(countSensedManna() ?? 0)),
            Double(fullCapCheck(vectorToClosestManna?.magnitude ?? CGFloat.infinity)),
            Double(fullCapCheck(vectorToClosestManna?.theta ?? 0)),

            Double(halfCapCheck(countSensedArkons() ?? 0)),
            Double(fullCapCheck(vectorToClosestArkon?.magnitude ?? CGFloat.infinity)),
            Double(fullCapCheck(vectorToClosestArkon?.theta ?? 0))

        ))
    }
}
