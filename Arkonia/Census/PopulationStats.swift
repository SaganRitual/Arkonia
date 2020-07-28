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

    @Published var currentPopulation: Int = 0

    @Published var cAverageNeurons: Double = 0
    @Published var cBrainy: Int = 0
    @Published var maxCBrainy: Int = 0
    @Published var cNeurons: Int = 0
    @Published var cRoomy: Int = 0
    @Published var maxCRoomy: Int = 0

    var coreAverageAge: TimeInterval = 0
    var coreMaxAge: TimeInterval = 0 { didSet { highwaterStats.highwaterIf(.age, value: coreMaxAge) } }
    var coreMedAge: TimeInterval = 0
    weak var oldestArkon: Stepper?

    var coreAverageCOffspring: Double = 0
    var coreMaxCOffspring: Double = 0 { didSet { highwaterStats.highwaterIf(.cOffspring, value: coreMaxCOffspring) } }
    var coreMedCOffspring: Double = 0
    weak var busiestArkon: Stepper?

    var coreCurrentPopulation: Int = 0 { didSet { highwaterStats.highwaterIf(.population, value: Double(coreCurrentPopulation)) } }

    var coreCAverageNeurons: Double = 0 { didSet { highwaterStats.highwaterIf(.cAverageNeurons, value: coreCAverageNeurons) } }
    var coreCNeurons: Int = 0 { didSet { highwaterStats.highwaterIf(.cLiveNeurons, value: Double(coreCNeurons)) } }

    var coreCBrainy: Int = 0 { didSet { if coreCBrainy > coreMaxCBrainy { coreMaxCBrainy = coreCBrainy } } }
    var coreMaxCBrainy: Int = 0 { didSet { highwaterStats.highwaterIf(.brainy, value: Double(coreMaxCBrainy)) } }

    var coreCRoomy: Int = 10_000_000 { didSet {
        if coreCRoomy == 0 || coreMaxCRoomy == 0 { return }
        if coreCRoomy < coreMaxCRoomy { coreMaxCRoomy = coreCRoomy }
    } }

    var coreMaxCRoomy = 10_000_000 { didSet {
        if coreMaxCRoomy == 0 { return }
        highwaterStats.highwaterIf(.roomy, value: Double(coreMaxCRoomy))
    } }

    weak var brainiestArkon: Stepper?

    let highwaterStats = HighwaterStats()

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
            if coreMaxCRoomy > 0 && Int(value) < coreMaxCRoomy { coreMaxCRoomy = Int(value) }
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
        coreCurrentPopulation = 0
        coreCAverageNeurons = 0
        coreCBrainy = 0
        coreMaxCBrainy = 0
        coreCNeurons = 0
        coreCRoomy = 10_000_000
        coreMaxCRoomy = 10_000_000
    }

    func updateUI() {
        self.averageAge = self.coreAverageAge
        self.averageCOffspring = self.coreAverageCOffspring

        self.maxAge = self.coreMaxAge
        self.maxCOffspring = self.coreMaxCOffspring

        self.medAge = self.coreMedAge
        self.medCOffspring = self.coreMedCOffspring

        self.currentPopulation = self.coreCurrentPopulation

        self.cNeurons = self.coreCNeurons
        self.cAverageNeurons = self.coreCAverageNeurons
        self.cBrainy = self.coreCBrainy
        self.cRoomy = self.coreCRoomy

        highwaterStats.updateUI()
    }
}
