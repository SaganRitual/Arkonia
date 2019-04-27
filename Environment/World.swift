import Foundation
import SpriteKit

class World {
    static var shared: World!

    private static let sAngularVelocity =  1
    private static let sLinearVelocity  =  2
    private static let sOxygen          =  1
    private static let sPosition        =  2
    private static let sCMannaSensed    =  1
    private static let sClosestManna    =  2
    private static let sCArkonsSensed   =  1
    private static let sClosestArkon    =  2
    static let cSenseNeurons            =
        sAngularVelocity + sLinearVelocity + sOxygen + sPosition + sCMannaSensed +
        sClosestManna + sCArkonsSensed + sClosestArkon

    private static let mPower   = 1
    private static let mAStop   = 1
    private static let mARotate = 1
    private static let mAThrust = 1
    private static let mAWait   = 1
    static let cMotorNeurons    =
       mPower + mAStop + mARotate + mAThrust + mAWait

    var population = 0 { willSet { if newValue > maxPopulation { maxPopulation = newValue } } }
    private(set) var maxPopulation = 0

    var greatestLiveAge: TimeInterval = 0 { willSet { if newValue > maxAge { maxAge = newValue } } }
    private(set) var maxAge: TimeInterval = 0

    let timeLimit: TimeInterval? = 2000.0
    public var entropy: TimeInterval {
        guard let t = timeLimit else { return 0 }
        return min(Display.shared.gameAge / t, 1.0)
    }

    let physicsCoordinator = PhysicsCoordinator()

    init(_ scene: SKScene) {
        scene.physicsWorld.gravity = CGVector.zero
        scene.physicsWorld.speed = 1.0
        scene.physicsWorld.contactDelegate = physicsCoordinator
    }
}
