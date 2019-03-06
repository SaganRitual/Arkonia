import Foundation
import SpriteKit

class World {
    static var shared: World!

    // angular velocity
    // r, θ to the origin, so they can evolve to stay in bounds
    // r, θ to the nearest food
    // velocity dx, dy relative to origin
    private static let cSenseNeurons = 7

    // Three (x, y) pairs as thrust vectors
    private static let cMotorNeurons = 6

    let arkonsPortal: SKSpriteNode
    let netPortal: SKSpriteNode
    private let physics: Physics

    init() {
        World.setSelectionControls()

        self.arkonsPortal = Display.shared.getPortal(quadrant: 1)
        self.netPortal = Display.shared.getPortal(quadrant: 0)

        let repeller = SKFieldNode.radialGravityField()
        repeller.strength = -0.05
        repeller.falloff = 2.0
        repeller.isEnabled = true
        arkonsPortal.addChild(repeller)

        self.physics = Physics()
    }

    static func setSelectionControls() {
        ArkonCentralDark.selectionControls.cSenseNeurons = World.cSenseNeurons
        ArkonCentralDark.selectionControls.cLayersInStarter = 2
        ArkonCentralDark.selectionControls.cMotorNeurons = World.cMotorNeurons
        ArkonCentralDark.selectionControls.cGenerations = 10000
    }
}
