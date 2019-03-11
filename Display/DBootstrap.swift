import Foundation
import SpriteKit

class DBootstrap: NSObject, SKSceneDelegate {
    var scene: SKScene
    var selfReference: DBootstrap?

    var components = [() -> Void]()
    var scratchComponents = [() -> Void]()

    init(_ scene: SKScene) {
        self.scene = scene

        super.init()

        self.components = [
            createDisplay, createPortalServer, createWorld,
            createArkonery, createMannaFactory, createDStatsPortal,
            liftoff
        ]

        selfReference = self
    }

    func launch()  { scene.delegate = self }
    func liftoff() {
        scene.delegate = Display.shared
        selfReference = nil
    }

    func createArkonery() {
        let a = World.shared.arkonsPortal
        let n = World.shared.netPortal
        ArkonFactory.shared = ArkonFactory(arkonsPortal: a, netPortal: n)
    }

    func createDisplay()      { Display.shared = Display(scene) }
    func createMannaFactory() { MannaFactory.shared = MannaFactory() }
    func createPortalServer() { DPortalServer.shared = DPortalServer(scene) }
    func createDStatsPortal() { DStatsPortal.shared = DStatsPortal(9) }
    func createWorld()        { World.shared = World() }

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        if scratchComponents.isEmpty { scratchComponents = components }
        let fn = scratchComponents.removeFirst()
        fn()
    }
}
