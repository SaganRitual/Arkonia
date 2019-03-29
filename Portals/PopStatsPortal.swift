import Foundation
import SpriteKit

class PopStatsPortal {
    var hiWaterCLiveArkons = 0

    init(_ portal: GeneralStats) {
        portal.setUpdater(subportal: 4, field: 0) { [weak self] in
            guard let myself = self else { preconditionFailure() }
            let c = World.shared.population.getCLiveArkons()
            if c > myself.hiWaterCLiveArkons { myself.hiWaterCLiveArkons = c }
            return String(format: "Live arkons: %d", c)
        }

        portal.setUpdater(subportal: 4, field: 1) { [weak self] in
            guard let myself = self else { preconditionFailure() }
            return String(format: "Hi water: %d", myself.hiWaterCLiveArkons)
        }

        portal.setUpdater(subportal: 4, field: 2) {
            return String(format: "Pending fab: %d", ArkonFactory.shared.cPending)
        }
    }
}
