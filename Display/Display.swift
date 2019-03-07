import Foundation
import SpriteKit

class Display: NSObject, SKSceneDelegate {
    static var shared: Display!

    var currentTime: TimeInterval = 0
    private var frameCount = 0
    private var kNet: KNet?
    private var kNets = [SKSpriteNode: KNet]()
    private var quadrants = [Int: SKSpriteNode]()
    public weak var scene: SKScene?
    public var tickCount = 0

    init(_ scene: SKScene) {
        self.scene = scene
        super.init()
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

    func getPortal(quadrant: Int) -> SKSpriteNode {
        if let p = quadrants[quadrant] { return p }
        let q = DPortalServer.shared.getPortal(quadrant)
        quadrants[quadrant] = q
        return q
    }

    var firstPass = true

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        defer { self.currentTime = currentTime }
        if self.currentTime == 0 { return }

        if firstPass {
            Arkonery.shared.spawnStarterPopulation(cArkons: 100)
            firstPass = false
            return
        }

        if let protoArkon = Arkonery.shared.pendingArkons.popFront() {
//            print("SKSceneDelegate launching Arkon(\(protoArkon.fishNumber))")
            protoArkon.launch()
        }

        tickCount += 1

        Arkonery.shared.trackNotableArkon()
        DebugPortal.shared.tick()

        if let kNet = self.kNet {
            DNet(kNet).display(via: World.shared.netPortal)
            self.kNet = nil
        }
    }
}
