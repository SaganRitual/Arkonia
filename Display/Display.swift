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

//        let dragField = SKFieldNode.dragField()
//        dragField.categoryBitMask = ArkonCentralLight.PhysicsBitmask.dragField.rawValue
//        dragField.strength = 100.0
//        dragField.isEnabled = true
//        dragField.minimumRadius = Float(max(
//            PortalServer.shared.arkonsPortal.size.width,
//            PortalServer.shared.arkonsPortal.size.height
//        ) / 2.0)

//        PortalServer.shared.arkonsPortal.addChild(dragField)

        self.portalServer.clockPortal.setUpdater { [weak self] in return self?.gameAge ?? 0 }
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

    var survivorCount = 0
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        Display.displayCycle = .updateStarted
        defer { Display.displayCycle = .actions }

        defer { self.currentTime = currentTime }
        if self.currentTime == 0 { self.timeZero = currentTime; return }

        tickCount += 1

        PortalServer.shared.arkonsPortal.children.forEach {
            guard let a = ($0 as? Karamba) else { return }
            if a.arkon == nil { return }
            guard a.isReadyForTick else { return }
            guard a.isAlive else { return }
            a.tick()
        }

        let populationGoal = 10
        let scaledPeriod = Int(ceil(CGFloat(4) * ArkonFactory.scale))
        let scaledAbsolute = Int(CGFloat(Int.max) * ArkonFactory.scale)
//        print("tc", scaledPeriod, scaledAbsolute, tickCount, tickCount % scaledPeriod, tickCount < scaledAbsolute)
        if tickCount % scaledPeriod == 0 && tickCount < scaledAbsolute {
            let p = PortalServer.shared.arkonsPortal.children.filter { $0 is Karamba }.count

            if p < populationGoal {
//                print("wtf", scaledPeriod, scaledAbsolute, tickCount, tickCount % scaledPeriod, tickCount < scaledAbsolute)
                (0..<((populationGoal - p) / 5)).forEach { _ in
//                    print("tf", $0, Karamba.backlogCount)
//                    Karamba.backlogCount += 1

                    Karamba.makeDrone(geneticParentFishNumber: nil, geneticParentGenome: nil)
                }
            }
        }

        if let kNet = self.kNet {
            DNet(kNet).display(via: PortalServer.shared.netPortal)
            self.kNet = nil
        }
    }
}
