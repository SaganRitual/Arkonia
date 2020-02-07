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

    let mBiases: [Matrix<Double>]
    let mWeights: [Matrix<Double>]

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

        self.mBiases = Net.makeBiasesVectors(self.layers, self.biases)
        self.mWeights = Net.makeWeightsVectors(self.layers, self.weights)
    }

    static func makeBiasesVectors(_ layers: [Int], _ biases: [Double]) -> [Matrix<Double>] {
        var ncSS = 0
        var biasesVectors = [Matrix<Double>]()

        for _ in 0..<layers.count - 1 {
            defer { ncSS += 1 }
            let nc1 = layers[ncSS + 1]

            let b = Matrix<Double>((0..<nc1).map { [biases[$0]] })

            biasesVectors.append(b)
        }

        return biasesVectors
    }

    static func makeWeightsVectors(_ layers: [Int], _ weights: [Double]) -> [Matrix<Double>] {
        var ncSS = 0
        var weightsVectors = [Matrix<Double>]()

        for _ in 0..<layers.count - 1 {
            defer { ncSS += 1 }
            let nc0 = layers[ncSS + 0]
            let nc1 = layers[ncSS + 1]

            let W = Matrix<Double>((0..<nc1).map { col in
                (0..<nc0).map { row in weights[col * nc0 + row] }
            })

            weightsVectors.append(W)
        }

        return weightsVectors
    }

    static func computeParameters(_ layers: [Int]) -> (Int, Int) {
        let cWeights = zip(layers.dropLast(), layers.dropFirst()).reduce(0) { $0 + ($1.0 * $1.1) }
        let cBiases = layers.dropFirst().reduce(0, +)
        return (cWeights, cBiases)
    }

    static func arctan(_ x: Double) -> Double { Surge.atan(x) }
    static func bentidentity(_ x: Double) -> Double { ((Surge.sqrt(x * x + 1.0) - 1.0) / 2.0) + x }
    static func binarystep(_ x: Double) -> Double { x < 0.0 ? 0.0 : 1.0 }
    static func gaussian(_ x: Double) -> Double { Surge.exp(-(x * x)) }
    static func identity(_ x: Double) -> Double { x }
    static func leakyrelu(_ x: Double) -> Double { x < 0.0 ? (0.01 * x) : x }
    static func logistic(_ x: Double) -> Double { 1.0 / (1.0 + Surge.exp(-x)) }
    static func sinc(_ x: Double) -> Double { x == 0.0 ? 1.0 : Surge.sin(x) / x }
    static func sinusoid(_ x: Double) -> Double {  Surge.sin(x) }
    static func softplus(_ x: Double) -> Double { Surge.log(1.0 + Surge.exp(x)) }
    static func softsign(_ x: Double) -> Double { x / (1 + abs(x)) }

    static func sqnl(_ x: Double) -> Double {
        switch x {
        case -2.0..<0.0: return x + x * x / 4.0
        case 0.0..<2.0:  return x - x * x / 4.0
        case 2.0...:     return 1.0
        default:         return -1.0
        }
    }

    static func tanh(_ x: Double) -> Double { return CoreGraphics.tanh(x) }

    static let funcs = [
        arctan, bentidentity, binarystep, gaussian, identity, leakyrelu,
        logistic, sinc, sinusoid, softplus, softsign, sqnl, tanh
    ]

    func getMotorOutputs(_ sensoryInputs: [Double]) -> [Double] {
        var inputsToNextLayer = Matrix<Double>(column: sensoryInputs)

        for (W, B) in zip(mWeights, mBiases) {
            let t1 = Surge.mul(W, inputsToNextLayer)
            let t2 = Surge.add(t1, B)
            let t3 = t2.map { [Net.sinusoid($0.first!)] }

            inputsToNextLayer = Matrix<Double>(t3)
        }

        return (0..<inputsToNextLayer.rows).map { inputsToNextLayer[$0, 0] }
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
        Debug.log(level: 93) { "Generate from scratch = \(fromScratch)" }
        return fromScratch
    }

    enum NetMutation: CaseIterable {
        case passThru, addDuplicatedLayer, addMutatedLayer, addRandomLayer, dropLayer
    }

    static func mutateNetStructure(_ layers: [Int]) -> [Int] {
        // 80% chance that the structure won't change at all
        if Int.random(in: 0..<100) < 80 { return layers }

        let strippedNet = Array(layers.dropFirst())
        var newNet: [Int]

        switch NetMutation.allCases.randomElement() {
        case .passThru:           newNet = strippedNet
        case .addDuplicatedLayer: newNet = addDuplicatedLayer(strippedNet)
        case .addMutatedLayer:    newNet = addMutatedLayer(strippedNet)
        case .addRandomLayer:     newNet = addRandomLayer(strippedNet)
        case .dropLayer:          newNet = dropLayer(strippedNet)
        case .none:               fatalError()
        }

        if newNet.isEmpty { newNet.append(Arkonia.cMotorNeurons) }

        newNet.insert(Arkonia.cSenseNeurons, at: 0)
        newNet.append(Arkonia.cMotorNeurons)

        return newNet
    }

    static func addDuplicatedLayer(_ layers: [Int]) -> [Int] {
        let insertPoint = Int.random(in: 1..<layers.count)
        var toMutate = layers
        toMutate.insert(toMutate[insertPoint], at: insertPoint)
        return toMutate
    }

    static func addMutatedLayer(_ layers: [Int]) -> [Int] {
        let insertPoint = Int.random(in: 1..<layers.count)
        var structureToMutate = layers
        let mag = Int.random(in: 1..<2)
        let sign = Bool.random() ? 1 : -1
        let L = abs(structureToMutate[insertPoint] + sign * mag)
        let mutatedLayer = (L == 0) ? 1 : L

        structureToMutate.insert(mutatedLayer, at: insertPoint)
        return structureToMutate
    }

    static func addRandomLayer(_ layers: [Int]) -> [Int] {
        let insertPoint = Int.random(in: 1..<layers.count)
        var toMutate = layers
        toMutate.insert(Int.random(in: 1..<10), at: insertPoint)
        return toMutate
    }

    static func dropLayer(_ layers: [Int]) -> [Int] {
        let howMany = Int.random(in: 1..<layers.count)
        var toMutate = layers

        for _ in 0..<howMany {
            let dropPoint = Int.random(in: 1..<toMutate.count)
            toMutate.remove(at: dropPoint)
        }

        return toMutate
    }

    static func newLayersFromScratch() -> [Int] { Net.layersTemplate }
}
