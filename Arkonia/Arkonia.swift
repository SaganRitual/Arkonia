import GameplayKit
import SpriteKit

class Arkonia {
    static let zoomFactor: CGFloat = 4
    static let arkonScaleFactor: CGFloat = 0.5
    static let mannaScaleFactor: CGFloat = 0.5
    static let noseScaleFactor: CGFloat = 0.75

    static let senseGridCRings = 8
    static let senseGridSide = 1 + 2 * senseGridCRings
    static let cSenseGridlets = senseGridSide * senseGridSide
    static let cSenseNeuronsSpatial = cSenseGridlets * 2
    static let cSenseNeuronsNonSpatial = 4 + cPollenators * 2
    static let cSenseNeurons = cSenseNeuronsSpatial + cSenseNeuronsNonSpatial
    static let cMotorNeurons = 2
    static let cMotorGridlets = cSenseGridlets - 1

    static let allowSpawning = true
    static let cMannaMorsels = 5000
    static let cPollenators = 5

    // vars so I can change them from the debugger
    static var debugColorIsEnabled = false
    static var debugMessageLevel = 183
    static var debugMessageToConsole = true

    static let funkyCells: CGFloat? = 2 / zoomFactor
    static let initialPopulation = 50
    static let maxPopulation = Int.max
    static let worldTimeLimit: TimeInterval? = nil//5000
    static let standardSpeedCellsPerSecond: CGFloat = 25

    static let mannaColorBlendMaximum: CGFloat = 0.70
    static let mannaColorBlendMinimum: CGFloat = 0.10
    static let mannaFullGrowthDurationSeconds: TimeInterval = 5

    static let mannaRebloomDelayMinimum: TimeInterval = 0.2
    static let mannaRebloomDelayMaximum: TimeInterval = 1.0

    static let arkonMinRestDuration: TimeInterval = 0
    static let arkonMaxRestDuration: TimeInterval = 0

    static let one_ms = UInt64(1e6) // # ns in one ms

    static var mannaColorBlendRangeWidth: CGFloat
        { mannaColorBlendMaximum - mannaColorBlendMinimum }

    static let realSecondsPerArkoniaDay: TimeInterval = 60
    static let darknessAsPercentageOfDay: TimeInterval = 0.40
    static let arkoniaDaysPerSeason: TimeInterval = 5
    static let arkoniaDaysPerYear: TimeInterval = 2 * arkoniaDaysPerSeason
    static let winterAsPercentageOfYear: TimeInterval = 0.40
    static let maximumBrightnessAlpha: CGFloat = 1
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
