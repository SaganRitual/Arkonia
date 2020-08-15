import SwiftUI

/// Census hits core vars only, only on the census dispatch queue; ui vars
/// are on the main queue. Note: there's no sync to keep the two out of here
/// simultaneously. Rather, the census manages them together, so don't go
/// calling into this class willy-nilly

class UpdateTrigger: ObservableObject {
    @Published var updateTrigger: Bool = false
    func toggle() { self.updateTrigger.toggle() }
}

class PopulationStats: ObservableObject {
    var averageAge: TimeInterval = 0
    var maxAge: TimeInterval = 0
    var medAge: TimeInterval = 0

    var averageCOffspring: Double = 0
    var maxCOffspring: Double = 0
    var medCOffspring: Double = 0

    var currentPopulation: Int = 0

    var cAverageNeurons: Double = 0
    var cBrainy: Int = 0
    var maxCBrainy: Int = 0
    var cNeurons: Int = 0
    var cRoomy: Int = 0
    var maxCRoomy: Int = 0

    var hudUpdateTrigger = UpdateTrigger()

    var foodSuccessLineChartControls = FoodSuccessLineChartControls()

    weak var oldestArkon: Stepper?
    weak var busiestArkon: Stepper?
    weak var brainiestArkon: Stepper?

    let highwaterStats = HighwaterStats()

    enum MaxIf { case brainiest, busiest, oldest, roomiest }
    func maxIf(_ maxIf: MaxIf, value: Double, arkon: Stepper) {
        switch maxIf {
        case .brainiest:
            if Int(value) > cBrainy { cBrainy = Int(value); brainiestArkon = arkon }
        case .busiest:
            if value > maxCOffspring { maxCOffspring = value; busiestArkon = arkon }
        case .oldest:
            if value > maxAge { maxAge = value; oldestArkon = arkon }
        case .roomiest:
            if maxCRoomy > 0 && Int(value) < maxCRoomy { maxCRoomy = Int(value) }
        }
    }

    func resetCore() {
        oldestArkon = nil; busiestArkon = nil; brainiestArkon = nil

        averageAge = 0
        maxAge = 0
        medAge = 0
        averageCOffspring = 0
        maxCOffspring = 0
        medCOffspring = 0
        currentPopulation = 0
        cAverageNeurons = 0
        cBrainy = 0
        maxCBrainy = 0
        cNeurons = 0
        cRoomy = 10_000_000
        maxCRoomy = 10_000_000
    }
}
