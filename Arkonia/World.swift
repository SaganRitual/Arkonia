import Foundation
import SpriteKit

class World {
    static var shared: World!

    private static let cSenseNeurons = 4    // r, θ to the origin, velocity dx, dy relative to origin
    private static let cMotorNeurons = 6    // Three (x, y) pairs as thrust vectors

    var arkonery: Arkonery
    let dispatchQueue = DispatchQueue(label: "arkonia.surreal.dispatch.queue")
    var portal: SKSpriteNode

    init() {
        World.setSelectionControls()

        let q = Display.shared.getPortal(quadrant: 0)
        let p = Display.shared.getPortal(quadrant: 1)
        self.portal = p

        let repeller = SKFieldNode.radialGravityField()
        repeller.strength = -0.1
        repeller.falloff = 1.2
        repeller.isEnabled = true
//        repeller.minimumRadius = 100.0
        p.addChild(repeller)

        Arkonery.shared = Arkonery(arkonsPortal: p, netPortal: q)
        self.arkonery = Arkonery.shared
        self.arkonery.postInit()

        FDecoder.shared = FDecoder()
        Mutator.shared = Mutator()
    }

    func postInit() {
        // Starter population
        (-50..<0).forEach { _ in
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
