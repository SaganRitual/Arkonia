import SwiftUI

/// Census hits core vars only, only on the census dispatch queue; ui vars
/// are on the main queue. Note: there's no sync to keep the two out of here
/// simultaneously. Rather, the census manages them together, so don't go
/// calling into this class willy-nilly
class HighwaterStats: ObservableObject {
    @Published var age: TimeInterval = 0
    @Published var allBirths: Int = 0
    @Published var brainy = 0
    @Published var cLiveNeurons = 0
    @Published var cAverageNeurons = 0.0
    @Published var cOffspring = 0.0
    @Published var population = 0
    @Published var roomy = 0

    var coreAge: TimeInterval = 0
    var coreAllBirths: Int = 0
    var coreBrainy = 0
    var coreCLiveNeurons = 0
    var coreCAverageNeurons = 0.0
    var coreCOffspring = 0.0
    var corePopulation = 0
    var coreRoomy = 10_000_000

    enum HighwaterIf {
        case age, brainy, cLiveNeurons, cAverageNeurons
        case cOffspring, population, roomy
    }

    func highwaterIf(_ highwaterIf: HighwaterIf, value: Double) {
        switch highwaterIf {
        case .age: if value > self.coreAge { self.coreAge = value }
        case .brainy: if Int(value) > self.coreBrainy { self.coreBrainy = Int(value) }
        case .cLiveNeurons: if Int(value) > self.coreCLiveNeurons { self.coreCLiveNeurons = Int(value) }
        case .cAverageNeurons: if value > self.coreCAverageNeurons { self.coreCAverageNeurons = value }
        case .cOffspring: if value > self.coreCOffspring { self.coreCOffspring = value }
        case .population: if Int(value) > self.corePopulation { self.corePopulation = Int(value) }
        case .roomy: if self.coreRoomy > 0 && Int(value) < self.coreRoomy { self.coreRoomy = Int(value) }
        }
    }

    func updateUI() {
        age = coreAge
        allBirths = coreAllBirths
        cLiveNeurons = coreCLiveNeurons
        cOffspring = coreCOffspring
        population = corePopulation
        cAverageNeurons = coreCAverageNeurons
        brainy = coreBrainy
        roomy = coreRoomy
    }
}
