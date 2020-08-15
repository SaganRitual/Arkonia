import Foundation

/// Note: there's no sync to keep the census agent and the UI from coming in
/// here simultaneously. Rather, the census manages them together, so don't go
/// calling into this class willy-nilly
class HighwaterStats {
    var age: TimeInterval = 0
    var allBirths: Int = 0
    var brainy = 0
    var cLiveNeurons = 0
    var cAverageNeurons = 0.0
    var cOffspring = 0.0
    var population = 0
    var roomy = 0

    enum HighwaterIf {
        case age, brainy, cLiveNeurons, cAverageNeurons
        case cOffspring, population, roomy
    }

    func highwaterIf(_ highwaterIf: HighwaterIf, value: Double) {
        switch highwaterIf {
        case .age: if value > self.age { self.age = value }
        case .brainy: if Int(value) > self.brainy { self.brainy = Int(value) }
        case .cLiveNeurons: if Int(value) > self.cLiveNeurons { self.cLiveNeurons = Int(value) }
        case .cAverageNeurons: if value > self.cAverageNeurons { self.cAverageNeurons = value }
        case .cOffspring: if value > self.cOffspring { self.cOffspring = value }
        case .population: if Int(value) > self.population { self.population = Int(value) }
        case .roomy: if self.roomy > 0 && Int(value) < self.roomy { self.roomy = Int(value) }
        }
    }
}
