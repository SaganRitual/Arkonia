import Foundation
import SpriteKit

class Display: NSObject, SKSceneDelegate {
    static var shared: Display!

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

        self.portalServer.clockPortal.setUpdater { [weak self] in return self?.gameAge ?? 0 }
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

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        // Mostly so the clock will stop running
        if ArkonFactory.shared.cLiveArkons <= 0 && ArkonFactory.shared.hiWaterCLiveArkons > 0 { return }

        defer { self.currentTime = currentTime }

        if self.currentTime == 0 { self.timeZero = currentTime; return }

        if firstPass {
            ArkonFactory.shared.spawnStarterPopulation(cArkons: 100)
            firstPass = false
            return
        }

        if let protoArkon = ArkonFactory.shared.pendingArkons.popFront() { protoArkon.launch() }

        if scene.physicsWorld.contactDelegate == nil && ArkonFactory.shared.pendingArkons.isEmpty {
            scene.physicsWorld.contactDelegate = World.shared.physics
            scene.physicsWorld.speed = 1.0
        }

        tickCount += 1

        ArkonFactory.shared.trackNotableArkon()
//        DStatsPortal.shared!.tick()

        if let kNet = self.kNet {
            DNet(kNet).display(via: PortalServer.shared.netPortal)
            self.kNet = nil
        }
    }
}
