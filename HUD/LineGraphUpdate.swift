import Foundation
import SpriteKit

enum LineGraphUpdate {
    static func getAgeUpdater(_ lgAge: LineGraph) -> SKAction? {
        let pullStats = SKAction.run {
            guard let scene = Display.shared?.scene else { return }
            guard let portal = scene.childNode(withName: "arkons_portal") as? SKSpriteNode
                else { return }

            let liveArkons: [Karamba] = portal.children.compactMap { $0 as? Karamba }

            let liveCount = liveArkons.count
            guard liveCount > 0 else { return }

            let sorted = liveArkons.sorted { $0.arkon.status.age < $1.arkon.status.age }

            let average = liveArkons.reduce(0) {
                CGFloat($0) + CGFloat($1.scab.status.age)
            } / CGFloat(liveArkons.count)

            let median: CGFloat

            if liveCount % 2 == 1 {
                let medianSS = liveCount / 2
                median = CGFloat(sorted[medianSS].arkon.status.age)
            } else if liveCount > 0 {
                let upper = CGFloat(sorted[liveCount / 2].arkon.status.age)
                let lower = CGFloat(sorted[(liveCount / 2) - 1].arkon.status.age)
                median = (upper + lower) / 2
            } else {
                preconditionFailure()
            }

            guard let m = sorted.last?.scab.status.age else { return }
            let maxAge = CGFloat(m)

            lgAge.addSamples(average: average, median: median, sum: maxAge)
        }

        return pullStats
    }
}
