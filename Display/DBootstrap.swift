import Foundation
import SpriteKit

class DBootstrap: NSObject, SKSceneDelegate {

    enum LaunchPhase: CaseIterable {
        case createDisplay, createWorld, createArkonery, createMannaFactory, createDrones
    }

    var currentTime: TimeInterval = 0
    var launchPhaseIterator = LaunchPhase.allCases.makeIterator()
    var scene: SKScene
    var selfReference: DBootstrap?

    init(_ scene: SKScene) {
        self.scene = scene
        super.init()
    }

    func launch()  { scene.delegate = self; selfReference = self }

    func liftoff() {
//        print("liftoff")
        scene.delegate = Display.shared
        selfReference = nil
    }

    func createArkonery()     { ArkonFactory.shared = ArkonFactory() }
    func createDisplay()      { Display.shared = Display(scene) }
    func createDrones()       { Karamba.createDrones(1) }
    func createMannaFactory() { MannaFactory.shared = MannaFactory() }
    func createWorld()        { World.shared = World(scene) }

    func didEvaluateActions(for scene: SKScene) {
//        print(".physics")
    }

    func didFinishUpdate(for scene: SKScene) {
//        print(".limbo")
    }

    func didSimulatePhysics(for scene: SKScene) {
//        print(".finishUpdate")
    }

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
//        print(".beginUpdate")

        defer { Display.currentTime = currentTime }
        if Display.currentTime == 0 { Display.timeZero = currentTime; return }

        guard let p = launchPhaseIterator.next() else { liftoff(); return }

        scene.run(SKAction.run { [weak self] in
            switch p {
            case .createDisplay:      self?.createDisplay()
            case .createWorld:        self?.createWorld()
            case .createArkonery:     self?.createArkonery()
            case .createMannaFactory: self?.createMannaFactory()
            case .createDrones:       self?.createDrones()
            }
        })
    }
}
