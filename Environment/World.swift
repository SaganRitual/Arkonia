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

    private var population_ = Population.population([])
    var population: Population {
        get {
            if populationChanged { population_ = population_.updateStatusCache() }
            return population_
        }

        set { population_ = newValue }
    }

    var populationChanged = true

    let timeLimit: TimeInterval? = 2000.0
    public var entropy: TimeInterval {
        guard let t = timeLimit else { return 0 }
        return min(Display.shared.gameAge / t, 1.0)
    }

    let physics: Physics

    init() {
        World.setSelectionControls()

        self.physics = Physics()

        PortalServer.shared.generalStatsPortals.setUpdater(subportal: 0, field: 4) { [weak self] in
            guard let myself = self else { preconditionFailure() }
            return String(format: "Food value: %.1f%%", 100 * (1.0 - myself.entropy))
        }
    }

    static func setSelectionControls() {
        ArkonCentralDark.selectionControls.cSenseNeurons = World.cSenseNeurons
        ArkonCentralDark.selectionControls.cLayersInStarter = 2
        ArkonCentralDark.selectionControls.cMotorNeurons = World.cMotorNeurons
        ArkonCentralDark.selectionControls.cGenerations = 10000
    }
}
