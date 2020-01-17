import Surge

class Net {

    static var layersTemplate = [
        Arkonia.cSenseNeurons, Arkonia.cMotorNeurons, Arkonia.cMotorNeurons
    ]

    static let dispatchQueue = DispatchQueue(
        label: "ak.net.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .default)
    )

    let activatorFunction: (_: Double) -> Double
    let biases: [Double]
    let cBiases: Int
    let cWeights: Int
    let layers: [Int]
    let weights: [Double]

    static func makeNet(
        parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?,
        parentActivator: ((_: Double) -> Double)?, _ onComplete: @escaping (Net) -> Void
    ) {
        dispatchQueue.async {
            let newNet = Net(parentBiases, parentWeights, layers, parentActivator)
            onComplete(newNet)
        }
    }

    private init(
        _ parentBiases: [Double]?, _ parentWeights: [Double]?, _ layers: [Int]?,
        _ parentActivator: ((_: Double) -> Double)?
    ) {
        if let L = layers {
            self.layers = Net.mutateNetStructure(L)
        } else {
            self.layers = Net.newLayersFromScratch()
        }

        (cWeights, cBiases) = Net.computeParameters(self.layers)

        self.biases = Net.mutateNetStrand(parentStrand: parentBiases, targetLength: cBiases)
        self.weights = Net.mutateNetStrand(parentStrand: parentWeights, targetLength: cWeights)

        self.activatorFunction = Net.mutateActivator(parentActivator: parentActivator)
    }

    static func computeParameters(_ layers: [Int]) -> (Int, Int) {
        let cWeights = zip(layers.dropLast(), layers.dropFirst()).reduce(0) { $0 + ($1.0 * $1.1) }
        let cBiases = layers.dropFirst().reduce(0, +)
        return (cWeights, cBiases)
    }

    static func arctan(_ x: Double) -> Double { return atan(x) }
    static func bentidentity(_ x: Double) -> Double { return ((sqrt(x * x + 1.0) - 1.0) / 2.0) + x }
    static func binarystep(_ x: Double) -> Double { return x < 0.0 ? 0.0 : 1.0 }
    static func gaussian(_ x: Double) -> Double { return exp(-(x * x)) }
    static func identity(_ x: Double) -> Double { return x }
    static func leakyrelu(_ x: Double) -> Double { return x < 0.0 ? (0.01 * x) : x }
    static func logistic(_ x: Double) -> Double { return 1.0 / (1.0 + exp(-x)) }
    static func sinc(_ x: Double) -> Double { return x == 0.0 ? 1.0 : sin(x) / x }
    static func sinusoid(_ x: Double) -> Double { return sin(x) }
    static func softplus(_ x: Double) -> Double { return log(1.0 + exp(x)) }
    static func softsign(_ x: Double) -> Double { return x / (1 + abs(x)) }

    static func sqnl(_ x: Double) -> Double {
        if x > 2.0 { return 1.0 }
        if x >= 0.0 { return x - x * x / 4.0 }
        if x >= -2.0 { return x + x * x / 4.0 }
        return -1.0
    }

    static func tanh(_ x: Double) -> Double { return CoreGraphics.tanh(x) }

    static let funcs = [
        arctan, bentidentity, binarystep, gaussian, identity, leakyrelu,
        logistic, sinc, sinusoid, softplus, softsign, sqnl, tanh
    ]

    func getMotorOutputs(_ sensoryInputs: [Double]) -> [Double] {
        assert(sensoryInputs.count == Arkonia.cSenseNeurons)

        var ncSS = 0
        var a0 = Matrix<Double>(column: sensoryInputs)

        Debug.log("layers = \(layers)", level: 29)

        for _ in 0..<layers.count - 1 {
            defer { ncSS += 1 }
            let nc0 = layers[ncSS + 0]
            let nc1 = layers[ncSS + 1]

            let W = Matrix<Double>((0..<nc1).map { col in
                (0..<nc0).map { row in self.weights[col * nc0 + row] }
            })

            let b = Matrix<Double>((0..<nc1).map { [self.biases[$0]] })

//            let b = Matrix<Double>((0..<nc1).map { _ in [Double.random(in: -1.0..<1.0)] })

            Debug.log("W.columns = \(W.columns), a0.rows = \(a0.rows), a0 = \(a0)", level: 29)

            let t2 = Surge.mul(W, a0)
            let t3 = Surge.add(t2, b)
            let t4 = t3.joined()
//            a0 = Matrix<Double>(t4.map { [AFn.function[AFn.FunctionName.sigmoid]!($0)] })
            a0 = Matrix<Double>(t4.map { [constrain(activatorFunction($0), lo: -1, hi: 1)] })
        }

//        Debug.log("mo", (0..<a0.rows).map { a0[$0, 0] })
        return (0..<a0.rows).map { a0[$0, 0] }
    }

    static func mutateActivator(parentActivator: ((_: Double) -> Double)?) -> (_: Double) -> Double {
        guard let p = parentActivator else { return funcs.randomElement()! }

        return Int.random(in: 0..<100) > 90 ? funcs.randomElement()! : p
    }

    static func mutateNetStrand(parentStrand p: [Double]?, targetLength: Int) -> [Double] {
        if let parentStrand = p,
            let firstPass = Mutator.shared.mutateRandomDoubles(parentStrand) {

            let c = firstPass.count

            if c > targetLength {
                return Array(firstPass.prefix(targetLength))
            } else if c < targetLength {
                return firstPass + (c..<targetLength).map { _ in Double.random(in: -1..<1) }
            }

            return firstPass
        }

        let fromScratch = (0..<targetLength).map { _ in Double.random(in: -1..<1) }
        Debug.log("Generate from scratch = \(fromScratch)", level: 93)
        return fromScratch
    }

    static func mutateNetStructure(_ layers: [Int]) -> [Int] {

        var mutated = [Arkonia.cSenseNeurons]
        let cOriginalLayers = layers.count

        for L in 1..<cOriginalLayers {
            switch Int.random(in: 0..<100) {

            case  0..<80:
                mutated.append(layers[L])

            case 80..<90: continue

            case  90..<95:
                mutated.append(layers[L])
                mutated.append(Int.random(in: 1..<10))

            case  95..<100:
                mutated.append(Int.random(in: 1..<10))

            default:
                fatalError()
            }
        }

        if mutated.count == 1 { mutated.append(Arkonia.cMotorNeurons) }

        mutated.append(Arkonia.cMotorNeurons)

        return mutated
    }

    static func newLayersFromScratch() -> [Int] { Net.layersTemplate }
}
