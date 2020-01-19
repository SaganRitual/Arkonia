import SpriteKit

func six(_ string: String?) -> String { return String(string?.prefix(50) ?? "<no input>") }

class Arkonia {
    typealias OnComplete1p = (Int) -> Void

    static let zoomFactor: CGFloat = 4
    static let arkonScaleFactor: CGFloat = 0.8
    static let mannaScaleFactor: CGFloat = 0.1
    static let noseScaleFactor: CGFloat = 0.75

    static let senseGridCRings = 1
    static let senseGridSide = 1 + 2 * senseGridCRings
    static let cSenseGridlets = senseGridSide * senseGridSide
    static let cSenseNeuronsSpatial = 2 * cSenseGridlets
    static let cSenseNeuronsNonSpatial = 4
    static let cSenseNeurons = cSenseNeuronsSpatial + cSenseNeuronsNonSpatial
    static let cMotorNeurons = 9 - 1
    static let cMotorGridlets = cMotorNeurons + 1

    static let allowSpawning = true
    static let cMannaMorsels = 8000
    static let debugColorIsEnabled = true
    static let debugMessageLevel = 96
    static let debugMessageToConsole = true
    static let energyTransferRateInJoules: CGFloat = maxMannaEnergyContentInJoules * 2.0
    static let fudgeMassFactor: CGFloat = 0.1
    static let funkyCells = true
    static let initialPopulation = 25

    static let co2BaseCost: CGFloat = 1.02
    static let co2MaxLevel: CGFloat = 50
    static let oxygenCostPerTick: CGFloat = 0.001

    static let inhaleFudgeFactor: CGFloat = 2.0
    static let spawnOverhead: CGFloat = 1.5

    static let mannaColorBlendMaximum: CGFloat = 0.35
    static let mannaColorBlendMinimum: CGFloat = 0.15
    static let mannaFullGrowthDurationSeconds: TimeInterval = 1
    static let mannaInitialRebloomDelay = 2.0
    static let maxMannaEnergyContentInJoules: CGFloat = 500

    static var mannaColorBlendRangeWidth: CGFloat
        { mannaColorBlendMaximum - mannaColorBlendMinimum }

    static var mannaGrowthRateJoulesPerSecond: CGFloat {
        return maxMannaEnergyContentInJoules / CGFloat(mannaFullGrowthDurationSeconds)
    }
}

extension Arkonia {
    static func tickTheWorld(_ queue: DispatchQueue, _ tick: @escaping () -> Void) {
        // This vomitosis is because I can't figure out how to get
        // asyncAfter to create a barrier task; it just runs concurrently
        // with the others, and causes crashes. Tried with DispatchWorkItem
        // too, but that didn't work even when using async(flags:execute:)
        queue.asyncAfter(deadline: .now() + 1) {
            queue.async(flags: .barrier) { tick(); tickTheWorld(queue, tick) }
        }
    }
}