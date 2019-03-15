import Foundation
import SpriteKit

struct GeneStatsPortal {
    static private var highWaterMark = 0

    init(_ generalStatsPortals: GeneralStats) {
        generalStatsPortals.setUpdater(subportal: 1, field: 0) {
            let total = World.shared.population.getCLiveGenes()
            return String(format: "Live genes: %d", total)
        }

        generalStatsPortals.setUpdater(subportal: 1, field: 1) {
            return String(format: "Longest: %d", World.shared.population.getLongestGenomeLength())
        }

        generalStatsPortals.setUpdater(subportal: 1, field: 2) {
            return String(
                format: "Median: %d", World.shared.population.getMedianLivingGenomeLength()
            )
        }

        generalStatsPortals.setUpdater(subportal: 1, field: 3) {
            let cLiveGenes = Double(World.shared.population.getCLiveGenes())
            let cLiveArkons = Double(World.shared.population.getCLiveArkons())
            return String(
                format: "Average: %.1f", cLiveGenes / cLiveArkons
            )
        }

        generalStatsPortals.setUpdater(subportal: 1, field: 4) {
            let cLiveGenes = World.shared.population.getCLiveGenes()

            if cLiveGenes > GeneStatsPortal.highWaterMark {
                GeneStatsPortal.highWaterMark = cLiveGenes
            }

            return String(format: "Hi water: %d", GeneStatsPortal.highWaterMark)
        }
    }
}
