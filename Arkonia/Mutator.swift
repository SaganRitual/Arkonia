import GameplayKit

class Mutator {
    static let shared = Mutator()

    let rng = GKGaussianDistribution(randomSource: GKARC4RandomSource(), mean: 0, deviation: 33)

    func mutate(from value: Double) -> Double {
        let nu = Double(rng.nextUniform())
        Debug.log(level: 121) { "from \(value) to \(value + nu)" }
        return value + nu
    }

    func mutateRandomDoubles(_ inDoubles: [Double]) -> [Double]? {
        if Int.random(in: 0..<100) < 90 { return inDoubles }

        let b = Double.random(in: 0..<0.05)
        var cMutate = b * Double(inDoubles.count)  // max 10% of genome

        let i = Int(cMutate)
        if i == 0 && Bool.random() {
            Debug.log(level: 121) { "no mutation" }
            return nil
        }

        cMutate = Double(i) + ((i == 0) ? 1 : 0)
        var outDoubles = inDoubles
//        var debugMessage = ""

        while cMutate > 0 {
            let wherefore = Int.random(in: 0..<inDoubles.count)
            let mutated = mutate(from: inDoubles[wherefore])
            outDoubles[wherefore] = mutated

//            Debug.log(level: 121) {
//                debugMessage += "at \(wherefore) from \(inDoubles[wherefore]) to \(mutated); "
//                return nil  // Don't log anything; that will happen at the end
//            }

            cMutate -= 1
        }

//        Debug.log(level: 121) { return debugMessage.isEmpty ? nil : "Mutations(\(b)): \(debugMessage)" }
        return outDoubles
    }
}
