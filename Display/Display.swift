import Foundation
import SpriteKit

class Display: NSObject, SKSceneDelegate {
    static var shared: Display!

    var currentTime: TimeInterval = 0
    private var frameCount = 0
    private var kNets = [SKSpriteNode: KNet]()
    private var quadrants = [Int: SKSpriteNode]()
    public weak var scene: SKScene?
    public var tickCount = 0

    init(_ scene: SKScene) {
        self.scene = scene
        DPortalServer.shared = DPortalServer(scene)

        super.init()

        scene.delegate = self
        scene.physicsWorld.gravity = CGVector.zero

        DebugPortal.shared = DebugPortal(self)
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
        kNets[portal] = kNet
    }

    func getPortal(quadrant: Int) -> SKSpriteNode {
        if let p = quadrants[quadrant] { return p }
        let q = DPortalServer.shared.getPortal(quadrant)
        quadrants[quadrant] = q
        return q
    }

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        tickCount += 1
        self.currentTime = currentTime

        DebugPortal.shared.tick()

        if case let .alive(parentFishNumber, newborn) = Arkonery.shared.launchpad {
            newborn.launch(parentFishNumber: parentFishNumber)
            Arkonery.shared.launchpad = .empty
        }

        if kNets.isEmpty { return }
        kNets.forEach { DNet($0.1).display(via: $0.0) }
        kNets.removeAll()
    }
}
