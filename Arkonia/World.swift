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

    var arkonery: Arkonery
    let dispatchQueue = DispatchQueue(label: "arkonia.surreal.dispatch.queue")
    private let physics: Physics
    var portal: SKSpriteNode

    init() {
        World.setSelectionControls()

        let arkonsPortal = Display.shared.getPortal(quadrant: 1)
        let netPortal = Display.shared.getPortal(quadrant: 0)
        self.portal = arkonsPortal

        let repeller = SKFieldNode.radialGravityField()
        repeller.strength = -0.5
        repeller.falloff = 1.2
        repeller.isEnabled = true
        arkonsPortal.addChild(repeller)

        Arkonery.shared = Arkonery(arkonsPortal: arkonsPortal, netPortal: netPortal)
        self.arkonery = Arkonery.shared
        self.arkonery.postInit()

        self.physics = Physics()
        FDecoder.shared = FDecoder()
        Mutator.shared = Mutator()
    }

    func postInit() { self.arkonery.spawnStarterPopulation(cArkons: 200) }

    static func setSelectionControls() {
        ArkonCentralDark.selectionControls.cSenseNeurons = World.cSenseNeurons
        ArkonCentralDark.selectionControls.cLayersInStarter = 2
        ArkonCentralDark.selectionControls.cMotorNeurons = World.cMotorNeurons
        ArkonCentralDark.selectionControls.cGenerations = 10000
    }
}
