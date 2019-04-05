import Foundation
import SpriteKit

enum Population {
    case population([Arkon])

    init(_ population: [Arkon]) { self = .population(population) }

    private func getArkon(for sprite: SKNode) -> Arkon? { return (sprite as? SKSpriteNode)?.arkon }

    func getArkon(for fishNumber: Int?) -> Arkon? {
        guard let fn = fishNumber else { return nil }
        guard case let .population(p) = self else { preconditionFailure() }

        let q = p.first { $0.fishNumber == fn }
        if q == nil { print("Couldn't find", fn, p.count) }
        return q
    }

    func getArkons() -> [Arkon] {
        guard case let .population(p) = self else { preconditionFailure() }
        return p.isEmpty ? [] : p
    }

    enum Eraser {
        case double(Double, Int), int(Int, Int)

        func isLessThan(_ rhs: Eraser) -> Bool {
            switch (self, rhs) {
            case (.double(let lp, let lf), .double(let rp, let rf)):
                if lp == rp { return lf < rf }
                return lp < rp

            case (.int(let lp, let lf), .int(let rp, let rf)):
                if lp == rp { return lf < rf }
                return lp < rp

            default: preconditionFailure()
            }
        }

        func isLessThan(_ lhs: Double, _ rhs: Double) -> Bool { return lhs < rhs }
        func isLessThan(_ lhs: Int, _ rhs: Int) -> Bool { return lhs < rhs }
    }

    func getArkonsByAge() -> [Arkon] {
        return getArkons().sorted {
            let lhs = Eraser.double($0.status.age, $0.fishNumber)
            let rhs = Eraser.double($1.status.age, $1.fishNumber)
            return lhs.isLessThan(rhs)
        }
    }

    func getArkonsByGeneCounts() -> [Arkon] {
        return getArkons().sorted {
            let lhs = Eraser.int($0.genome.count, $0.fishNumber)
            let rhs = Eraser.int($1.genome.count, $1.fishNumber)
            return lhs.isLessThan(rhs)
        }
    }

    func getArkonsByOffspring() -> [Arkon] {
        return getArkons().sorted {
            let lhs = Eraser.int($0.status.cOffspring, $0.fishNumber)
            let rhs = Eraser.int($1.status.cOffspring, $1.fishNumber)
            return lhs.isLessThan(rhs)
        }
    }

    func getCLiveArkons() -> Int { return getArkons().count }

    func getCLiveGenes() -> Int {
        let p = getArkons()
        if p.isEmpty { return 0 }
        return p.reduce(0) { $0 + $1.genome.count }
    }

    func getLongestGenomeLength() -> Int {
        return getArkonsByGeneCounts().last?.genome.count ?? 0
    }

    func getMedianLivingGenomeLength() -> Int {
        let p = getArkonsByGeneCounts()

        return p.isEmpty ? 0 : p[p.count / 2].genome.count
    }

    func updateStatusCache() -> Population {
        if !World.shared.populationChanged { return self }

        let sprites = PortalServer.shared.arkonsPortal.children
        let arkons: [Arkon] = sprites.compactMap { node in
            guard let sprite = node as? SKSpriteNode else { return nil }
            guard let arkon = sprite.arkon else { return nil }
            return arkon
        }

        World.shared.populationChanged = false
        return .population(arkons)
    }

}
