import Foundation
import SpriteKit

class World {
    static var shared: World!

    // velocity dx, dy relative to origin
    // r, θ to the nearest food
    private static let cSenseNeurons = 4

    // Three (x, y) pairs as thrust vectors
    private static let cMotorNeurons = 6

    var arkonery: Arkonery
    let dispatchQueue = DispatchQueue(label: "arkonia.surreal.dispatch.queue")
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

        FDecoder.shared = FDecoder()
        Mutator.shared = Mutator()
    }

    func postInit() {
        // Starter population
        (-200..<0).forEach { _ in
            self.arkonery.spawn(parentID: nil, parentGenome: Arkonery.aboriginalGenome)
        }
    }

    static func setSelectionControls() {
        ArkonCentralDark.selectionControls.cSenseNeurons = World.cSenseNeurons
        ArkonCentralDark.selectionControls.cLayersInStarter = 2
        ArkonCentralDark.selectionControls.cMotorNeurons = World.cMotorNeurons
        ArkonCentralDark.selectionControls.cGenerations = 10000
    }
}
