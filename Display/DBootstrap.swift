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
            createDisplay, createWorld,
            createArkonery, createMannaFactory,
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
        ArkonFactory.shared = ArkonFactory()
    }

    func createDisplay()      { Display.shared = Display(scene) }
    func createMannaFactory() { MannaFactory.shared = MannaFactory() }
    func createWorld()        { World.shared = World() }

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        if scratchComponents.isEmpty { scratchComponents = components }
        let fn = scratchComponents.removeFirst()
        fn()
    }
}
