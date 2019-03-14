import Foundation
import SpriteKit

struct HealthStatsPortal {
    static private var highWaterMark = 0.0

    init(_ generalStatsPortals: GeneralStats) {
        generalStatsPortals.setUpdater(subportal: 2, field: 0) {
            if Arkon.currentAgeOfOldestArkon > HealthStatsPortal.highWaterMark {
                HealthStatsPortal.highWaterMark = Arkon.currentAgeOfOldestArkon
            }

            return String(format: "Oldest: %.2f", Arkon.currentAgeOfOldestArkon)
        }

        generalStatsPortals.setUpdater(subportal: 2, field: 1) {
            return String(format: "Record: %.2f", HealthStatsPortal.highWaterMark)
        }

        generalStatsPortals.setUpdater(subportal: 2, field: 2) {
            return String(format: "Average: %.2f", Arkon.averageAgeOfLivingArkons)
        }

        generalStatsPortals.setUpdater(subportal: 2, field: 3) {
            let ages = HealthStatsPortal.getAges()
            return String(format: "Median: %.2f", ages.isEmpty ? 0 : ages[ages.count / 2])
        }
   }

    static func getAges() -> [TimeInterval] {
        return PortalServer.shared.arkonsPortal.children.compactMap { node in
            guard let sprite = node as? SKSpriteNode else { return nil }
            guard let arkon = sprite.arkon else { return nil }
            return arkon.myAge
        }.sorted(by: <)
    }
}
