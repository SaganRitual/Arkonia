import Foundation
import SpriteKit

class Display: NSObject, SKSceneDelegate {
    static var shared: Display!

    private var frameCount = 0
    private var kNets = [SKSpriteNode: KNet]()
    private var portalServer: DPortalServer
    private var quadrants = [Int: SKSpriteNode]()
    public weak var scene: SKScene?

    init(_ scene: SKScene) {
        self.scene = scene
        self.portalServer = DPortalServer(scene)

        super.init()

        scene.delegate = self
        scene.physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.01)
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
        let q = portalServer.getPortal(quadrant)
        quadrants[quadrant] = q
        return q
    }

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        World.shared.arkonery.tick()
        if kNets.isEmpty { return }
        kNets.forEach { DNet($0.1).display(via: $0.0) }
        kNets.removeAll()
    }
}
