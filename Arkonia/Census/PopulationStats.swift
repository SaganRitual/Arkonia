import SwiftUI

class PopulationStats: ObservableObject {
    @Published var averageAge: TimeInterval = 0
    @Published var maxAge: TimeInterval = 0
    @Published var medAge: TimeInterval = 0
    weak var oldestArkon: Stepper?

    @Published var averageFoodHitRate: Double = 0
    @Published var maxFoodHitRate: Double = 0
    weak var bestAimArkon: Stepper?

    @Published var averageCOffspring: Double = 0
    @Published var maxCOffspring: Double = 0
    @Published var medCOffspring: Double = 0
    weak var busiestArkon: Stepper?

    @Published var allBirths: Int = 0
    @Published var currentPopulation: Int = 0

    @Published var cAverageNeurons: Double = 0
    @Published var cBrainy: Int = 0
    @Published var cNeurons: Int = 0
    @Published var cRoomy: Int = 0

    // swiftlint:disable function_parameter_count
    // Function Parameter Count Violation: Function should have 5 parameters or less
    func update(
        averageAge: TimeInterval, maxAge: TimeInterval, medAge: TimeInterval,
        averageFoodHitRate: Double, maxFoodHitRate: Double,
        averageCOffspring: Double, medCOffspring: Double, maxCOffspring: Double,
        allBirths: Int, currentPopulation: Int,
        oldestArkon: Stepper?, bestAimArkon: Stepper?, busiestArkon: Stepper?,
        cNeurons: Int, cBrainy: Int, cRoomy: Int
    ) {
        DispatchQueue.main.async {
            self.averageAge = averageAge
            self.averageFoodHitRate = averageFoodHitRate
            self.averageCOffspring = averageCOffspring

            self.maxAge = maxAge
            self.maxFoodHitRate = maxFoodHitRate
            self.maxCOffspring = maxCOffspring

            self.medAge = medAge
            self.medCOffspring = medCOffspring

            self.allBirths = allBirths
            self.currentPopulation = currentPopulation

            self.oldestArkon = oldestArkon
            self.bestAimArkon = bestAimArkon
            self.busiestArkon = busiestArkon

            self.cNeurons = cNeurons
            self.cAverageNeurons = Double(cNeurons) / Double(currentPopulation)
            self.cBrainy = cBrainy
            self.cRoomy = cRoomy
        }
    }
    // swiftlint:enable function_parameter_count
}
