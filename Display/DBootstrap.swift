import Foundation
import SpriteKit

class DBootstrap: NSObject, SKSceneDelegate {
    var scene: SKScene
    var selfReference: DBootstrap?

    init(_ scene: SKScene) {
        self.scene = scene
        super.init()
    }

    func launch()  {
        scene.delegate = self

        let actions = SKAction.sequence([
            SKAction.run { [weak self] in self!.createDisplay() },
            SKAction.run { [weak self] in self!.createWorld() },
            SKAction.run { [weak self] in self!.createArkonery() },
            SKAction.run { [weak self] in self!.createMannaFactory() },
            SKAction.run { [weak self] in self!.createDrones() }
        ])

        scene.run(actions, completion: liftoff)
    }

    func liftoff() {
        scene.delegate = Display.shared
        selfReference = nil
    }

    func createArkonery() {
        ArkonFactory.shared = ArkonFactory()
    }

    func createDisplay()      { Display.shared = Display(scene) }
    func createDrones()       { Karamba.createDrones(500) }
    func createMannaFactory() { MannaFactory.shared = MannaFactory() }
    func createWorld()        { World.shared = World(scene) }
}
