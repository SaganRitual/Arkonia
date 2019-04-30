import Foundation
import SpriteKit

enum LineGraphUpdate {
    static func getAgeUpdater(_ lgAge: LineGraph) -> SKAction? {
        let pullStats = SKAction.run {
            guard let scene = Display.shared?.scene else { return }
            guard let portal = scene.childNode(withName: "arkons_portal") as? SKSpriteNode
                else { return }

            let liveArkons: [Karamba] = portal.children.compactMap { $0 as? Karamba }
            if liveArkons.isEmpty { return }

            let sorted = liveArkons.sorted { $0.age < $1.age }

            let average = liveArkons.reduce(0) {
                CGFloat($0) + CGFloat($1.age)
            } / CGFloat(liveArkons.count)

            let median: CGFloat

            if liveArkons.count % 2 == 1 {
                let medianSS = liveArkons.count / 2
                median = CGFloat(sorted[medianSS].age)
            } else if liveArkons.isEmpty {
                preconditionFailure()
            } else {
                let upper = CGFloat(sorted[liveArkons.count / 2].age)
                let lower = CGFloat(sorted[(liveArkons.count / 2) - 1].age)
                median = (upper + lower) / 2
            }

            guard let m = sorted.last?.age else { return }
            let maxAge = CGFloat(m)

            lgAge.addSamples(average: average, median: median, sum: maxAge)
        }

        return pullStats
    }

    static func getCGeneUpdater(_ lgGenes: LineGraph) -> SKAction? {
        let pullStats = SKAction.run {
            guard let scene = Display.shared?.scene else { return }
            guard let portal = scene.childNode(withName: "arkons_portal") as? SKSpriteNode
                else { return }

            let liveArkons: [Karamba] = portal.children.compactMap { $0 as? Karamba }
            if liveArkons.isEmpty { return }

            let sorted = liveArkons.sorted { $0.genome.count < $1.genome.count }

            let average = CGFloat(World.shared.cLiveGenes) / CGFloat(liveArkons.count)

            let median: CGFloat

            if liveArkons.count % 2 == 1 {
                let medianSS = liveArkons.count / 2
                median = CGFloat(sorted[medianSS].genome.count)
            } else if liveArkons.isEmpty {
                preconditionFailure()
            } else {
                let upper = CGFloat(sorted[liveArkons.count / 2].genome.count)
                let lower = CGFloat(sorted[(liveArkons.count / 2) - 1].genome.count)
                median = (upper + lower) / 2
            }

            guard let m = sorted.last?.genome.count else { return }
            let maxCGenes = CGFloat(m)

            lgGenes.addSamples(average: average, median: median, sum: maxCGenes)
        }

        return pullStats
    }

    static func getOffspringUpdater(_ lgOffspring: LineGraph) -> SKAction? {
        let pullStats = SKAction.run {
            guard let scene = Display.shared?.scene else { return }
            guard let portal = scene.childNode(withName: "arkons_portal") as? SKSpriteNode
                else { return }

            let liveArkons: [Karamba] = portal.children.compactMap { $0 as? Karamba }
            if liveArkons.isEmpty { return }

            let sorted = liveArkons.sorted { $0.cOffspring < $1.cOffspring }
            let total = liveArkons.reduce(0) { $0 + $1.cOffspring }
            let average = CGFloat(total) / CGFloat(liveArkons.count)

            let median: CGFloat

            if liveArkons.count % 2 == 1 {
                let medianSS = liveArkons.count / 2
                median = CGFloat(sorted[medianSS].cOffspring)
            } else if liveArkons.isEmpty {
                preconditionFailure()
            } else {
                let upper = CGFloat(sorted[liveArkons.count / 2].cOffspring)
                let lower = CGFloat(sorted[(liveArkons.count / 2) - 1].cOffspring)
                median = (upper + lower) / 2
            }

            guard let m = sorted.last?.cOffspring else { return }
            let maxCOffspring = CGFloat(m)

            lgOffspring.addSamples(average: average, median: median, sum: maxCOffspring)
        }

        return pullStats
    }
}
