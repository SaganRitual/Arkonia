import Foundation
import SpriteKit

class Display: NSObject, SKSceneDelegate {
    typealias SceneTickCallback = (_ portal: SKNode) -> Void

    private var frameCount = 0
    private var kNets = [SKNode: KNet]()
    private var portalServer: DPortalServer
    private var quadrants = [Int: SKNode]()
    private weak var scene: SKScene?
    private var tickCallbacks = [() -> Void]()

    init(_ scene: SKScene) {
        self.scene = scene
        self.portalServer = DPortalServer(scene)

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
    func display(_ kNet: KNet, portal: SKNode) {
        portal.removeAllChildren()
        kNets[portal] = kNet

        // We wait until here to set the delegate rather than setting
        // it up at app startup. The scene will start sending us updates
        // as soon as we set this, and we don't want updates until we're
        // all set up.
        nok(self.scene).delegate = ArkonCentralLight.display
    }

    func getPortal(quadrant: Int) -> SKNode {
        if let p = quadrants[quadrant] { return p }
        let q = portalServer.getPortal(quadrant)
        quadrants[quadrant] = q
        return q
    }

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        let ready = ArkonCentralLight.world?.update(currentTime, for: scene)
        guard ready == .flying else { return }

        if kNets.isEmpty { return }
        kNets.forEach { DNet($0.1).display(via: $0.0) }
        kNets.removeAll()

    }
}
