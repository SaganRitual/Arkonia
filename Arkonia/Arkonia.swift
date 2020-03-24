import SpriteKit

class Arkonia {
    typealias OnComplete1p = (Int) -> Void

    static let zoomFactor: CGFloat = 4
    static let arkonScaleFactor: CGFloat = 0.7
    static let mannaScaleFactor: CGFloat = 0.1
    static let noseScaleFactor: CGFloat = 0.75

    static let senseGridCRings = 4
    static let senseGridSide = 1 + 2 * senseGridCRings
    static let cSenseGridlets = senseGridSide * senseGridSide
    static let cSenseNeuronsSpatial = cSenseGridlets
    static let cSenseNeuronsNonSpatial = 4 + cFertileSpots * 2
    static let cSenseNeurons = cSenseNeuronsSpatial + cSenseNeuronsNonSpatial
    static let cMotorNeurons = 1
    static let cMotorGridlets = cSenseGridlets - 1

    static let netActivator = Net.logistic

    static let allowSpawning = true
    static let cMannaMorsels = 5000
    static let cFertileSpots = 5
    static let debugColorIsEnabled = false
    static var debugMessageLevel = 149 // var so we can change it on the fly
    static let debugMessageToConsole = true
    static let energyTransferRateInJoules: CGFloat = maxMannaEnergyContentInJoules * 2.0
    static let fudgeMassFactor: CGFloat = 0.1
    static let funkyCells: CGFloat? = nil//2 / zoomFactor
    static let initialPopulation = 50
    static let maxPopulation = Int.max
    static let worldTimeLimit: TimeInterval? = nil//5000

    static let co2BaseCost: CGFloat = 0//1.02
    static let co2MaxLevel: CGFloat = 50
    static let oxygenCostPerTick: CGFloat = 0//0.01
    static let neuronCostPerCycle: CGFloat = 0//0.01  // In joules

    static let inhaleFudgeFactor: CGFloat = 2.0
    static let spawnOverhead: CGFloat = 1.5

    static let mannaColorBlendMaximum: CGFloat = 0.35
    static let mannaColorBlendMinimum: CGFloat = 0.25
    static let mannaFullGrowthDurationSeconds: TimeInterval = 2
    static let maxMannaEnergyContentInJoules: CGFloat = 200
    static let mannaReplantBatchSize: Int = 100

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
