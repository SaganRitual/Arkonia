import Foundation
import SpriteKit

struct GeneStatsPortal {
    static private var highWaterMark = 0

    init(_ generalStatsPortals: GeneralStats) {
        generalStatsPortals.setUpdater(subportal: 1, field: 0) {
            let total = GeneStatsPortal.getCLiveGenes()
            return String(format: "Live genes: %d", total)
        }

        generalStatsPortals.setUpdater(subportal: 1, field: 1) {
            return String(format: "Longest: %d", ArkonFactory.shared.longestLivingGenomeLength)
        }

        generalStatsPortals.setUpdater(subportal: 1, field: 2) {
            return String(format: "Median: %d", ArkonFactory.shared.medianLivingGenomeLength)
        }

        generalStatsPortals.setUpdater(subportal: 1, field: 3) {
            let total = GeneStatsPortal.getCLiveGenes()
            return String(
                format: "Average: %.1f", Double(total) / Double(ArkonFactory.shared.cLiveArkons)
            )
        }

        generalStatsPortals.setUpdater(subportal: 1, field: 4) {
            let total = GeneStatsPortal.getCLiveGenes()
            if total > GeneStatsPortal.highWaterMark { GeneStatsPortal.highWaterMark = total }
            return String(format: "Hi water: %d", GeneStatsPortal.highWaterMark)
        }
    }

    static private func getCLiveGenes() -> Int {
        let counts = ArkonFactory.shared.getGeneCounts()
        return counts.reduce(0) { $0 + $1 }
    }
}
