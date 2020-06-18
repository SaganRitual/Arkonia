import GameplayKit
import SpriteKit

class Arkonia {
    static let zoomFactor: CGFloat = 4
    static let arkonScaleFactor: CGFloat = 0.3
    static let mannaScaleFactor: CGFloat = 0.5
    static let noseScaleFactor: CGFloat = 0.75

    static let allowSpawning = true
    static let cMannaMorsels = 0
    static let cPollenators = 5

    // vars so I can change them from the debugger
    static var debugColorIsEnabled = false
    static var debugMessageLevel = 205
    static var debugMessageToConsole = true
    static var debugGrid = true

    static let funkyCells: CGFloat? = nil //2 / zoomFactor
    static let initialPopulation = 10
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
