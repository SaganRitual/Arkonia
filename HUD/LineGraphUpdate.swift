import Foundation
import SpriteKit

enum LineGraphUpdate {
    static func getAgeStats(_ onComplete: @escaping (LineGraphInputSet?) -> Void) {
        func a() { SceneDispatch.shared.schedule(b) }

        func b() {
            let counts = ArkoniaScene.arkonsPortal.children.compactMap({ arkonSprite in
                (arkonSprite.userData?["stepper"] as? Stepper)?.net.cNeurons
            }).sorted()

            if counts.isEmpty { onComplete(nil); return }

            let total = CGFloat(counts.reduce(0, +))
            let average = total / CGFloat(counts.count)

            let median: CGFloat

            let medianSS = counts.count / 2

            if counts.count % 2 == 1 {
                median = CGFloat(counts[medianSS])
            } else {
                let upper = CGFloat(counts[medianSS])
                let lower = CGFloat(counts[medianSS - 1])
                median = CGFloat(upper + lower) / 2
            }

//            guard let maxCNeurons = counts.max() else { return }

            onComplete(LineGraphInputSet(average, median, total))
        }

        a()
    }

    static func getAgeUpdater(_ lgAge: LineGraph) -> SKAction? {
//        let pullStats = SKAction.run {
//            var ages = [Int]()
//
//            WorkItems.getAges { a, _ in ages = a
//                if ages.isEmpty { return }
//
//                let average = CGFloat(ages.reduce(0, +)) / CGFloat(ages.count)
//
//                let median: CGFloat
//
//                if ages.count % 2 == 1 {
//                    let medianSS = ages.count / 2
//                    median = CGFloat(ages[medianSS])
//                } else {
//                    let upper = CGFloat(ages.count / 2)
//                    let lower = CGFloat((ages.count / 2) - 1)
//                    median = CGFloat(upper + lower) / 2
//                }
//
//                guard let maxAge = ages.max() else { return }
//
//                lgAge.addSamples(average: average, median: median, sum: CGFloat(maxAge))
//            }
//        }
//
//        return pullStats
        return nil
    }
//
//    static func getCGeneUpdater(_ lgGenes: LineGraph) -> SKAction? {
//        let pullStats = SKAction.run {
//            guard let scene = Display.shared?.scene else { return }
//            guard let portal = scene.childNode(withName: "arkons_portal") as? SKSpriteNode
//                else { return }
//
//            let liveArkons: [Karamba] = portal.children.compactMap { $0 as? Karamba }
//            if liveArkons.isEmpty { return }
//
//            let sorted = liveArkons.sorted { $0.genome.count < $1.genome.count }
//
//            let average = CGFloat(World.shared.cLiveGenes) / CGFloat(liveArkons.count)
//
//            let median: CGFloat
//
//            if liveArkons.count % 2 == 1 {
//                let medianSS = liveArkons.count / 2
//                median = CGFloat(sorted[medianSS].genome.count)
//            } else if liveArkons.isEmpty {
//                preconditionFailure()
//            } else {
//                let upper = CGFloat(sorted[liveArkons.count / 2].genome.count)
//                let lower = CGFloat(sorted[(liveArkons.count / 2) - 1].genome.count)
//                median = (upper + lower) / 2
//            }
//
//            guard let m = sorted.last?.genome.count else { return }
//            let maxCGenes = CGFloat(m)
//
//            lgGenes.addSamples(average: average, median: median, sum: maxCGenes)
//        }
//
//        return pullStats
//    }
//
//    static func getOffspringUpdater(_ lgOffspring: LineGraph) -> SKAction? {
//        let pullStats = SKAction.run {
//            guard let scene = Display.shared?.scene else { return }
//            guard let portal = scene.childNode(withName: "arkons_portal") as? SKSpriteNode
//                else { return }
//
//            let liveArkons: [Karamba] = portal.children.compactMap { $0 as? Karamba }
//            if liveArkons.isEmpty { return }
//
//            let sorted = liveArkons.sorted { $0.cOffspring < $1.cOffspring }
//            let total = liveArkons.reduce(0) { $0 + $1.cOffspring }
//            let average = CGFloat(total) / CGFloat(liveArkons.count)
//
//            let median: CGFloat
//
//            if liveArkons.count % 2 == 1 {
//                let medianSS = liveArkons.count / 2
//                median = CGFloat(sorted[medianSS].cOffspring)
//            } else if liveArkons.isEmpty {
//                preconditionFailure()
//            } else {
//                let upper = CGFloat(sorted[liveArkons.count / 2].cOffspring)
//                let lower = CGFloat(sorted[(liveArkons.count / 2) - 1].cOffspring)
//                median = (upper + lower) / 2
//            }
//
//            guard let m = sorted.last?.cOffspring else { return }
//            let maxCOffspring = CGFloat(m)
//
//            lgOffspring.addSamples(average: average, median: median, sum: maxCOffspring)
//        }
//
//        return pullStats
//    }
}
