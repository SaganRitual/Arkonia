import Surge

enum Net {

    static func getMotorOutputs(_ sensoryInputs: [Double]) -> [Double] {
        assert(sensoryInputs.count == ArkoniaCentral.cSenses)

        let neuronCounts = [ArkoniaCentral.cSenses, 9, 9, ArkoniaCentral.cMotorNeurons]
        var ncSS = 0
        var a0 = Matrix<Double>(sensoryInputs.map { [$0] })

        for _ in 0..<neuronCounts.count - 1 {
            defer { ncSS += 1 }
            let nc0 = neuronCounts[ncSS + 0]
            let nc1 = neuronCounts[ncSS + 1]

            let W = Matrix<Double>((0..<nc1).map { _ in
                (0..<nc0).map { _ in Double.random(in: -10..<10) }
            })

            let b = Matrix<Double>((0..<nc1).map { _ in [Double.random(in: -1.0..<1.0)] })

            let t2 = Surge.mul(W, a0)
            let t3 = Surge.add(t2, b)
            let t4 = t3.joined()
//            a0 = Matrix<Double>(t4.map { [AFn.function[AFn.FunctionName.sigmoid]!($0)] })
            a0 = Matrix<Double>(t4.map { [sin($0)] })
        }

        return (0..<a0.rows).map { a0[$0, 0] }
    }

}
