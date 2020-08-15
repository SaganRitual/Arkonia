import Foundation

class Arkonia {
    static let zoomFactor: CGFloat = 20
    static let arkonScaleFactor: CGFloat = 0.4
    static let mannaScaleFactor: CGFloat = 0.5
    static let noseScaleFactor: CGFloat = 0.40
    static let toothScaleFactor: CGFloat = 2.0
    static let markerScaleFactor: CGFloat = 5

    static let allowSpawning = true
    static let cMannaMorsels = 6000
    static let cPollenators = 5

    // vars so I can change them from the debugger
    static var debugColorIsEnabled = false
    static var debugMessageLevel = 230
    static var debugMessageToConsole = true
    static var debugGrid = false

    static let funkyCells: CGFloat? = nil
    static let initialPopulation = 1

    static let worldTimeLimit: TimeInterval? = nil//5000
    static let standardSpeedCellsPerSecond: CGFloat = 25

    static let mannaColorBlendMaximum: CGFloat = 0.85
    static let mannaColorBlendMinimum: CGFloat = 0.10
    static let mannaFullGrowthDurationSeconds: TimeInterval = 5

    static let mannaRebloomDelayMinimum: TimeInterval = 0.2
    static let mannaRebloomDelayMaximum: TimeInterval = 1.0

    static let arkonMinRestDuration: TimeInterval = 0
    static let arkonMaxRestDuration: TimeInterval = 0

    static let one_ms = UInt64(1e6) // # ns in one ms

    static var mannaColorBlendRangeWidth: CGFloat
        { mannaColorBlendMaximum - mannaColorBlendMinimum }

    static let annualCyclePeriodDiurnalPeriods:  TimeInterval = 10
    static let annualCyclePeriodSeconds: TimeInterval = diurnalCyclePeriodSeconds * annualCyclePeriodDiurnalPeriods
    static let winterSolsticeDaylightPercentage: TimeInterval = 0.8
    static let diurnalFluctuation:        TimeInterval = 1     // Amplitude of diurnal curve
    static let diurnalCyclePeriodSeconds: TimeInterval = 60
    static let seasonalFluctuation:       TimeInterval = 1     // Amplitude of seasonal curve
    static let updateFrequencyHertz:      TimeInterval = 5
    static let winterAsPercentageOfYear:  TimeInterval = 0.5
}

extension Arkonia {
    static fileprivate let MainDispatchQueue = DispatchQueue(
        label: "ak.dispatch.q", attributes: .concurrent, target: DispatchQueue.global()
    )
}

func mainDispatch(_ execute: @escaping () -> Void) {
    Arkonia.MainDispatchQueue.async(execute: execute)
}
