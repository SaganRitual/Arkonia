import SpriteKit

func six(_ string: String?) -> String { return String(string?.prefix(50) ?? "<no input>") }

class Arkonia {
    typealias OnComplete1p = (Int) -> Void

    static let zoomFactor: CGFloat = 4
    static let arkonScaleFactor: CGFloat = 0.8
    static let mannaScaleFactor: CGFloat = 0.2
    static let noseScaleFactor: CGFloat = 0.75

    static let senseGridSide = 3
    static let cSenseGridlets = senseGridSide * senseGridSide
    static let cSenseNeuronsSpatial = 2 * cSenseGridlets
    static let cSenseNeuronsNonSpatial = 4
    static let cSenseNeurons = cSenseNeuronsSpatial + cSenseNeuronsNonSpatial
    static let cMotorNeurons = 9 - 1
    static let cMotorGridlets = cMotorNeurons + 1

    static let allowSpawning = true
    static let cMannaMorsels = 2000
    static let energyTransferRateInJoules: CGFloat = 200
    static let fudgeMassFactor: CGFloat = 0.01
    static let funkyCells = true
    static let maxMannaEnergyContentInJoules: CGFloat = 1000
    static let oxygenCostPerTick: CGFloat = 0.0005
    static let inhaleFudgeFactor: CGFloat = 2.0
    static let spawnOverhead: CGFloat = 1.5
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
