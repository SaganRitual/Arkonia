import Surge

class Net {
    static let cWeights = ArkoniaCentral.cSenseNeurons * 9 + 9 * 9 + 9 * ArkoniaCentral.cMotorNeurons

    let biases: [Double]
    let weights: [Double]

    init(parentBiases: [Double]?, parentWeights: [Double]?) {
        if let b = parentBiases { self.biases = World.mutator.mutateRandomDoubles(b)! }
        else { self.biases = (0..<23).map { _ in Double.random(in: -1..<1) } }

        if let w = parentWeights { self.weights = World.mutator.mutateRandomDoubles(w)! }
        else { self.weights = (0..<Net.cWeights).map { _ in Double.random(in: -1..<1) } }
    }

    func getMotorOutputs(_ sensoryInputs: [Double]) -> [Double] {
        assert(sensoryInputs.count == ArkoniaCentral.cSenseNeurons)

        let neuronCounts = [ArkoniaCentral.cSenseNeurons, 9, 9, ArkoniaCentral.cMotorNeurons]
        var ncSS = 0
        var a0 = Matrix<Double>(sensoryInputs.map { [$0] })

        for _ in 0..<neuronCounts.count - 1 {
            defer { ncSS += 1 }
            let nc0 = neuronCounts[ncSS + 0]
            let nc1 = neuronCounts[ncSS + 1]

            let W = Matrix<Double>((0..<nc1).map { col in
                (0..<nc0).map { row in self.weights[col * nc0 + row] }
            })

            let b = Matrix<Double>((0..<nc1).map { [self.biases[$0]] })

//            let b = Matrix<Double>((0..<nc1).map { _ in [Double.random(in: -1.0..<1.0)] })

            let t2 = Surge.mul(W, a0)
            let t3 = Surge.add(t2, b)
            let t4 = t3.joined()
//            a0 = Matrix<Double>(t4.map { [AFn.function[AFn.FunctionName.sigmoid]!($0)] })
            a0 = Matrix<Double>(t4.map { [sin($0)] })
        }

//        print("mo", (0..<a0.rows).map { a0[$0, 0] })
        return (0..<a0.rows).map { a0[$0, 0] }
    }

    static func randomWithGap() -> Double {
        let firstDouble = Double.random(in: -1..<1)
        let sign: Double = firstDouble >= 0 ? 1 : -1
        return firstDouble + (abs(firstDouble) < 0.5 ? (0.5 * sign) : 0)
    }

}
