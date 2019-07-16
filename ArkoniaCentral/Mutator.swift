class Mutator {
    var bellCurve = BellCurve()
    var outputGenome = [Double]()
    var sourceGenome = [Double]()

    func mutate(from value: Double) -> Double {
        let percentage = bellCurve.nextFloat()
        let newValue = Double(1.0 - percentage) * value
        return newValue
    }

    func mutateRandomDoubles(_ inDoubles: [Double]) -> [Double]? {
        let b = abs(bellCurve.nextFloat())
        var cMutate = 0.1 * Double(outputGenome.count) * Double(b)  // max 10% of genome
        precondition(abs(cMutate) != Double.infinity && cMutate != Double.nan)

        let i = Int(cMutate)
        guard i > 0 else { return nil }

        var outDoubles = [Double]()

        while cMutate > 0 {
            let wherefore = Int.random(in: 0..<outputGenome.count)
            outDoubles.insert(mutate(from: inDoubles[wherefore]), at: wherefore)
            cMutate -= 1
        }

        return outDoubles
    }
}
