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
    static var displayCycle: DisplayCycle = .limbo

    var appIsReadyToRun = false
    var currentTime: TimeInterval = 0
    private var frameCount = 0
    private var kNet: KNet?
    private var kNets = [SKSpriteNode: KNet]()
    private var portalServer: PortalServer!
    private var quadrants = [Int: SKSpriteNode]()
    public weak var scene: SKScene?
    public var tickCount = 0
    var timeZero: TimeInterval = 0

    var gameAge: TimeInterval { return currentTime - timeZero }

    init(_ scene: SKScene) {
        self.scene = scene
        self.portalServer = PortalServer(scene: scene)

        super.init()

        let dragField = SKFieldNode.dragField()
        dragField.categoryBitMask = ArkonCentralLight.PhysicsBitmask.dragField.rawValue
        dragField.strength = 100.0
        dragField.isEnabled = true
        dragField.minimumRadius = Float(max(
            PortalServer.shared.arkonsPortal.size.width,
            PortalServer.shared.arkonsPortal.size.height
        ) / 2.0)

        PortalServer.shared.arkonsPortal.addChild(dragField)

//        self.portalServer.clockPortal.setUpdater { [weak self] in return self?.gameAge ?? 0 }
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
    func display(_ kNet: KNet, portal: SKSpriteNode) {
        portal.removeAllChildren()
        self.kNet = kNet
    }

    var firstPass = true
    var babyFirstSteps = true

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        Display.displayCycle = .updateStarted
        defer { Display.displayCycle = .actions }

        defer { self.currentTime = currentTime }
        if self.currentTime == 0 { self.timeZero = currentTime; return }

        tickCount += 1

        let cm: [Karamba] = PortalServer.shared.arkonsPortal.children.compactMap {
            guard let a = ($0 as? Karamba) else { return nil }
            return a.scab.status.isAlive ? a : nil
        }

        cm.forEach { $0.tick() }

        if let kNet = self.kNet {
            DNet(kNet).display(via: PortalServer.shared.netPortal)
            self.kNet = nil
        }
    }
}
