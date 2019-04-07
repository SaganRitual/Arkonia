import Foundation
import SpriteKit

class World {
    static var shared: World!

    private static let sAngularVelocity =  1
    private static let sLinearVelocity  =  2
    private static let sPosition        =  2
    private static let sCMannaSensed    =  1
    private static let sClosestManna    =  2
    private static let sCArkonsSensed   =  1
    private static let sClosestArkon    =  2
    static let cSenseNeurons            =
        sAngularVelocity + sLinearVelocity + sPosition + sCMannaSensed +
        sClosestManna + sCArkonsSensed + sClosestArkon

    private static let mPower   = 1
    private static let mAStop   = 1
    private static let mARotate = 1
    private static let mAThrust = 1
    private static let mAWait   = 1
    static let cMotorNeurons    =
       mPower + mAStop + mARotate + mAThrust + mAWait

    private var population_ = Population.population([])
    var population: Population {
        get {
            if populationChanged { population_ = population_.updateStatusCache() }
            return population_
        }

        set { population_ = newValue }
    }

    var populationChanged = true

    let timeLimit: TimeInterval? = 2000.0
    public var entropy: TimeInterval {
        guard let t = timeLimit else { return 0 }
        return min(Display.shared.gameAge / t, 1.0)
    }

    let physics: Physics

    init(_ scene: SKScene) {
        self.physics = Physics(scene: scene)

//        PortalServer.shared.generalStatsPortals.setUpdater(subportal: 0, field: 4) { [weak self] in
//            guard let myself = self else { preconditionFailure() }
//            return String(format: "Food value: %.1f%%", 100 * (1.0 - myself.entropy))
//        }
    }
}
