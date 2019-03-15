import Foundation
import SpriteKit

struct PopStatsPortal {
    init(_ portal: GeneralStats) {
        portal.setUpdater(subportal: 4, field: 0) {
            return String(format: "Live arkons: %d", ArkonFactory.shared.cLiveArkons)
        }

        portal.setUpdater(subportal: 4, field: 1) {
            return String(format: "Hi water: %d", ArkonFactory.shared.hiWaterCLiveArkons)
        }

        portal.setUpdater(subportal: 4, field: 2) {
            return String(format: "Pending fab: %d", ArkonFactory.shared.cPending)
        }

        portal.setUpdater(subportal: 4, field: 3) {
            return String(format: "Pending launch: %d", ArkonFactory.shared.pendingArkons.count)
        }
    }
}
