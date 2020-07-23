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
    @Published var maxCOffspring: Int = 0
    weak var busiestArkon: Stepper?

    @Published var allBirths: Int = 0
    @Published var currentPopulation: Int = 0
    @Published var highwaterPopulation: Int = 0

    // swiftlint:disable function_parameter_count
    // Function Parameter Count Violation: Function should have 5 parameters
    // or less: it currently has 6
    func update(
        averageAge: TimeInterval, maxAge: TimeInterval, medAge: TimeInterval,
        averageFoodHitRate: Double, maxFoodHitRate: Double,
        averageCOffspring: Double, maxCOffspring: Int,
        allBirths: Int, currentPopulation: Int, highwaterPopulation: Int
    ) {
        DispatchQueue.main.async {
            self.averageAge = averageAge
            self.averageFoodHitRate = averageFoodHitRate
            self.averageCOffspring = averageCOffspring

            self.maxAge = maxAge
            self.maxFoodHitRate = maxFoodHitRate
            self.maxCOffspring = maxCOffspring

            self.medAge = medAge

            self.currentPopulation = currentPopulation
            self.allBirths = allBirths
            self.highwaterPopulation = highwaterPopulation
        }
    }
    // swiftlint:enable function_parameter_count
}
