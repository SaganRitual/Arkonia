import Foundation
import SpriteKit

class World {
    static var shared: World!

    private static let cSenseNeurons = 2    // r, θ to the origin
    private static let cMotorNeurons = 6    // Three (x, y) pairs as thrust vectors

    var arkonery: Arkonery
    let dispatchQueue = DispatchQueue(label: "arkonia.surreal.dispatch.queue")
    var portal: SKSpriteNode

    enum LaunchStage { case unready, flying }
    var launchStage = LaunchStage.unready

    init() {
        World.setSelectionControls()

        let p = Display.shared.getPortal(quadrant: 1)
        self.portal = p

        self.arkonery = Arkonery(portal: p)
        self.arkonery.postInit(self)

        _ = FDecoder()
        _ = Mutator()

        launchStage = .flying

//        portal.speed = 0.1

        (0..<25).forEach { _ in self.arkonery.launchArkon() }
//        portal.run(arkonery.tickAction)
    }

    static func setSelectionControls() {
        ArkonCentralDark.selectionControls.cSenseNeurons = World.cSenseNeurons
        ArkonCentralDark.selectionControls.cLayersInStarter = 2
        ArkonCentralDark.selectionControls.cMotorNeurons = World.cMotorNeurons
        ArkonCentralDark.selectionControls.cGenerations = 10000
    }
//
//    func update(_ currentTime: TimeInterval, for scene: SKScene) -> LaunchStage {
//        switch launchStage {
//        case .unready:
//            break
//
//        case .flying:
//            if self.isBusy { break }
//            portal.run(SKAction.run(experimental, queue: dispatchQueue))
//       }
//
//        return self.launchStage
//    }
}
