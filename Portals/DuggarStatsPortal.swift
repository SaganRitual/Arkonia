import Foundation
import SpriteKit

class DuggarStatsPortal {
    static var shared: DuggarStatsPortal?

    private var highWaterMark = 0

    init(_ generalStatsPortals: GeneralStats) {
        DuggarStatsPortal.shared = self

        generalStatsPortals.setUpdater(subportal: 5, field: 4) {// [weak self] in
            return ""
//            guard let myself = self else { preconditionFailure() }
//
//            let p = World.shared.population.getArkonsByOffspring().reversed()
//
//            let contenderForDuggarest_ = p.dropFirst()
//            let contenderForDuggarest = contenderForDuggarest_[contenderForDuggarest_.startIndex]
//            p.forEach { $0.status.isDuggarest = false}
//            contenderForDuggarest.status.isDuggarest = true
//
//            let greatestDuggarness = p[p.startIndex].status.cOffspring
//            if greatestDuggarness > myself.highWaterMark {
//                myself.highWaterMark = greatestDuggarness
//            }
//
//            return String(format: "Duggarest: %d", greatestDuggarness)
        }

        generalStatsPortals.setUpdater(subportal: 5, field: 3) { [weak self] in
            guard let myself = self else { preconditionFailure() }
            return String(format: "Record: %d", myself.highWaterMark)
        }

        generalStatsPortals.setUpdater(subportal: 5, field: 2) {
            let p = World.shared.population.getArkonsByOffspring()
            let average = Double(p.reduce(0) { $0 + $1.status.cOffspring }) / Double(p.count)

            return String(format: "Average: %.2f", average)
        }

        generalStatsPortals.setUpdater(subportal: 5, field: 1) {
            let p = World.shared.population.getArkonsByOffspring()
            let median = p.isEmpty ? 0 : p[p.count / 2].status.cOffspring
            return String(format: "Median: %d", median)
        }
    }
}
