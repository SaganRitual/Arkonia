import SwiftUI

/// Census hits core vars only, only on the census dispatch queue; ui vars
/// are on the main queue. Note: there's no sync to keep the two out of here
/// simultaneously. Rather, the census manages them together, so don't go
/// calling into this class willy-nilly
class PopulationStats: ObservableObject {
    @Published var averageAge: TimeInterval = 0
    @Published var maxAge: TimeInterval = 0
    @Published var medAge: TimeInterval = 0

    @Published var averageCOffspring: Double = 0
    @Published var maxCOffspring: Double = 0
    @Published var medCOffspring: Double = 0

    @Published var allBirths: Int = 0
    @Published var currentPopulation: Int = 0

    @Published var cAverageNeurons: Double = 0
    @Published var cBrainy: Int = 0
    @Published var maxCBrainy: Int = 0
    @Published var cNeurons: Int = 0
    @Published var cRoomy: Int = 0
    @Published var maxCRoomy: Int = 0

    var coreAverageAge: TimeInterval = 0
    var coreMaxAge: TimeInterval = 0
    var coreMedAge: TimeInterval = 0
    weak var oldestArkon: Stepper?

    var coreAverageCOffspring: Double = 0
    var coreMaxCOffspring: Double = 0
    var coreMedCOffspring: Double = 0
    weak var busiestArkon: Stepper?

    var coreAllBirths: Int = 0
    var coreCurrentPopulation: Int = 0

    var coreCAverageNeurons: Double = 0
    var coreCNeurons: Int = 0

    var coreCBrainy: Int = 0
    var coreMaxCBrainy: Int = 0

    var coreCRoomy: Int = 0
    var coreMaxCRoomy: Int = 0

    weak var brainiestArkon: Stepper?

    enum MaxIf { case brainiest, busiest, oldest, roomiest }
    func maxIf(_ maxIf: MaxIf, value: Double, arkon: Stepper) {
        switch maxIf {
        case .brainiest:
            if Int(value) > coreCBrainy { coreCBrainy = Int(value); brainiestArkon = arkon }
        case .busiest:
            if value > coreMaxCOffspring { coreMaxCOffspring = value; busiestArkon = arkon }
        case .oldest:
            if value > coreMaxAge { coreMaxAge = value; oldestArkon = arkon }
        case .roomiest:
            if Int(value) > coreMaxCRoomy { coreMaxCRoomy = Int(value) }
        }
    }

    func resetCore() {
        oldestArkon = nil; busiestArkon = nil; brainiestArkon = nil

        coreAverageAge = 0
        coreMaxAge = 0
        coreMedAge = 0
        coreAverageCOffspring = 0
        coreMaxCOffspring = 0
        coreMedCOffspring = 0
        coreAllBirths = 0
        coreCurrentPopulation = 0
        coreCAverageNeurons = 0
        coreCBrainy = 0
        coreMaxCBrainy = 0
        coreCNeurons = 0
        coreCRoomy = Int.max
        coreMaxCRoomy = Int.max
    }

    func updateUI() {
        self.averageAge = self.coreAverageAge
        self.averageCOffspring = self.coreAverageCOffspring

        self.maxAge = self.coreMaxAge
        self.maxCOffspring = self.coreMaxCOffspring

        self.medAge = self.coreMedAge
        self.medCOffspring = self.coreMedCOffspring

        self.allBirths = self.coreAllBirths
        self.currentPopulation = self.coreCurrentPopulation

        self.cNeurons = self.coreCNeurons
        self.cAverageNeurons = self.coreCAverageNeurons
        self.cBrainy = self.coreCBrainy
        self.cRoomy = self.coreCRoomy
    }
}
