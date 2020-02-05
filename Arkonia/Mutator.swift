import GameplayKit

class Mutator {
    static let shared = Mutator()

    let rng = GKGaussianDistribution(randomSource: GKARC4RandomSource(), mean: 0, deviation: 33)

    func mutate(from value: Double) -> Double {
        let percentage = rng.nextUniform()
        Debug.log(level: 94) { "percentage \(percentage)" }
        let newValue = Double(1.0 - percentage) * value
        return newValue
    }

    func mutateRandomDoubles(_ inDoubles: [Double]) -> [Double]? {
        let b = abs(rng.nextUniform())
        Debug.log(level: 94) { "double \(b)" }
        var cMutate = 0.1 * Double(inDoubles.count) * Double(b)  // max 10% of genome
        precondition(abs(cMutate) != Double.infinity && cMutate != Double.nan)

        let i = Int(cMutate)
        Debug.log(level: 94) { "mrd \(cMutate), \(i)" }
        guard i > 0 else { return nil }

        var outDoubles = inDoubles

        while cMutate > 0 {
            let wherefore = Int.random(in: 1..<inDoubles.count)
            outDoubles.insert(mutate(from: inDoubles[wherefore]), at: wherefore)
            cMutate -= 1
        }

        return outDoubles
    }
}
