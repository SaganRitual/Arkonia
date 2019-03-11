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

    public var entropy: TimeInterval { return min(Display.shared.gameAge * 0.001, 1000.0) }
    public var foodValue: Double { return 100.0 * (1.0 - entropy) }

    let physics: Physics

    init() {
        World.setSelectionControls()

        self.physics = Physics()

        PortalServer.shared.generalStats.setUpdater(subportal: 0, field: 4) { [weak self] in
            return String(format: "Food value: %.1f%", self?.foodValue ?? 0.0)
        }
    }

    static func setSelectionControls() {
        ArkonCentralDark.selectionControls.cSenseNeurons = World.cSenseNeurons
        ArkonCentralDark.selectionControls.cLayersInStarter = 2
        ArkonCentralDark.selectionControls.cMotorNeurons = World.cMotorNeurons
        ArkonCentralDark.selectionControls.cGenerations = 10000
    }
}
