import Surge

class Net {

    static var layersTemplate = [
        Arkonia.cSenseNeurons, Arkonia.cMotorNeurons, Arkonia.cMotorNeurons
    ]

    let activatorFunction: (_: Double) -> Double
    let biases: [Double]
    let cBiases: Int
    let cWeights: Int
    let layers: [Int]
    let weights: [Double]

    init(
        parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?,
        parentActivator: ((_: Double) -> Double)?
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

//        Debug.log("L", self.layers, self.layers.count, "b", cBiases, self.biases.count, "w", cWeights, self.weights.count)
    }

    deinit {
//        Debug.log("~Net()?")
    }

    static func computeParameters(_ layers: [Int]) -> (Int, Int) {
        var cWeights = 0
        for c in 0..<(layers.count - 1) {
            cWeights += layers[c] * layers[c + 1]
        }

        var cBiases = 0
        for b in 1..<layers.count {
            cBiases += layers[b]
        }

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
            let childStrand = Mutator.shared.mutateRandomDoubles(parentStrand) {
            Debug.log("Parent values \(parentStrand)", level: 93)
            Debug.log("Child values \(childStrand)", level: 93)
            return childStrand
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

    static func newLayersFromScratch() -> [Int] {
        var newLayers = Net.layersTemplate

        let layerInsertionOdds = Int.random(in: 1..<100)
        if abs(layerInsertionOdds) <= 30 {
            let insertionPoint = Int.random(in: 1..<newLayers.count)

            if layerInsertionOdds < 0 {
                newLayers.remove(at: insertionPoint)
            } else if layerInsertionOdds > 0 {
                newLayers.insert(Int.random(in: 1..<20), at: insertionPoint)
            }
        }

        return newLayers
    }

}
