import Foundation
import SpriteKit

enum DisplayCycle: Int {
    case limbo
    case updateStarted
    case actions, actionsComplete
    case physics, physicsComplete
    case constraints, constraintsComplete
    case updateComplete

    func isIn(_ state: DisplayCycle) -> Bool { return self.rawValue == state.rawValue }
    func isPast(_ milestone: DisplayCycle) -> Bool { return self.rawValue >= milestone.rawValue }
}

class Display: NSObject, SKSceneDelegate {
    static var shared: Display!

    static var currentTime: TimeInterval = 0
    static var displayCycle: DisplayCycle = .limbo
    static var timeZero: TimeInterval = 0

    var appIsReadyToRun = false
    private var frameCount = 0
    private var kNet: KNet?
    private var kNets = [SKSpriteNode: KNet]()
    private var quadrants = [Int: SKSpriteNode]()
    public weak var scene: SKScene?
    public var tickCount = 0

    var gameAge: TimeInterval { return Display.currentTime - Display.timeZero }

    init(_ scene: SKScene) {
        self.scene = scene
        super.init()
    }

    func didEvaluateActions(for scene: SKScene) {
        Display.displayCycle = .physics
    }

    func didSimulatePhysics(for scene: SKScene) {
        Display.displayCycle = .limbo
    }

    /**
     Schedule the kNet to be displayed on the next update.

     - Parameters:
         - kNet: The net to be displayed
         - portal: The portal on which to display it

     Does not display the net immediately, as we call it in a
     non-main thread context. We schedule it to be displayed on
     the next scene update

     */
    func scheduleNetDisplay(_ kNet: KNet, portal: SKSpriteNode) {
        portal.removeAllChildren()
        self.kNet = kNet
    }

    var firstPass = true
    var babyFirstSteps = true

    var survivorCount = 0
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        Display.displayCycle = .updateStarted
        defer {
            Display.displayCycle = .actions
            Display.currentTime = currentTime
        }

        tickCount += 1

        let portal = hardBind(scene.childNode(withName: "arkons_portal") as? SKSpriteNode)
        portal.children.forEach {
            guard let a = ($0 as? Karamba) else { return }
            guard a.isReadyForTick else { return }
            guard a.isAlive else { return }
            a.tick()
        }
    }
}
