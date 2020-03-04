import CoreGraphics
import Dispatch

class Net {

    static var layersTemplate = [
        Arkonia.cSenseNeurons, Arkonia.cMotorNeurons, Arkonia.cMotorNeurons
    ]

    static let dispatchQueue = DispatchQueue(
        label: "ak.net.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .utility)
    )

    let activatorFunction: (_: Double) -> Double
    let biases: [Double]
    let cBiases: Int
    let cWeights: Int
    let hotNet: BlasNet
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

//        hotNet = HotNet(self.layers, self.biases, self.weights)
        hotNet = BlasNet(self.layers, self.biases, self.weights)
    }

    static func computeParameters(_ layers: [Int]) -> (Int, Int) {
        let cWeights = zip(layers.dropLast(), layers.dropFirst()).reduce(0) { $0 + ($1.0 * $1.1) }
        let cBiases = layers.dropFirst().reduce(0, +)
        return (cWeights, cBiases)
    }
}

extension Net {
    static func arctan(_ x: Double) -> Double { atan(x) }
    static func bentidentity(_ x: Double) -> Double { ((sqrt(x * x + 1.0) - 1.0) / 2.0) + x }
    static func binarystep(_ x: Double) -> Double { x < 0.0 ? 0.0 : 1.0 }
    static func gaussian(_ x: Double) -> Double { exp(-(x * x)) }
    static func identity(_ x: Double) -> Double { x }
    static func leakyrelu(_ x: Double) -> Double { x < 0.0 ? (0.01 * x) : x }
    static func logistic(_ x: Double) -> Double { 1.0 / (1.0 + exp(-x)) }
    static func sinc(_ x: Double) -> Double { x == 0.0 ? 1.0 : sin(x) / x }
    static func sinusoid(_ x: Double) -> Double {  sin(x) }
    static func softplus(_ x: Double) -> Double { log(1.0 + exp(x)) }
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

    func getMotorOutputs(_ sensoryInputs: [Double], _ onComplete: @escaping ([Double]) -> Void) {
        hotNet.driveSignal(sensoryInputs, onComplete)
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
        let layerToDuplicate = layers.randomElement()
        let insertPoint = Int.random(in: 0..<layers.count)
        var toMutate = layers
        toMutate.insert(layerToDuplicate!, at: insertPoint)

        Debug.log(level: 120) { "addDuplicatedLayer to \(layers.count)-layer net: \(layerToDuplicate!) neurons, insert at \(insertPoint)" }
        return toMutate
    }

    static func addMutatedLayer(_ layers: [Int]) -> [Int] {
        let layerToMutate = layers.randomElement()
        let insertPoint = Int.random(in: 0..<layers.count)
        var structureToMutate = layers
        let mag = Int.random(in: 1..<2)
        let sign = Bool.random() ? 1 : -1
        let L = abs(layerToMutate! + sign * mag)
        let mutatedLayer = (L == 0) ? 1 : L

        structureToMutate.insert(mutatedLayer, at: insertPoint)

        Debug.log(level: 120) { "addMutatedLayer to \(layers.count)-layer net: \(layerToMutate!) neurons, insert at \(insertPoint)" }
        return structureToMutate
    }

    static func addRandomLayer(_ layers: [Int]) -> [Int] {
        let insertPoint = Int.random(in: 0..<layers.count)
        var toMutate = layers
        let cNeurons = Int.random(in: 1..<10)
        toMutate.insert(cNeurons, at: insertPoint)
        Debug.log(level: 120) { "addRandomLayer to \(layers.count)-layer net: \(cNeurons) neurons, insert at \(insertPoint)" }
        return toMutate
    }

    static func dropLayer(_ layers: [Int]) -> [Int] {
        let howMany = Int.random(in: 0..<layers.count)
        var toMutate = layers

        for _ in 0..<howMany {
            let dropPoint = Int.random(in: 0..<toMutate.count)
            toMutate.remove(at: dropPoint)
            Debug.log(level: 120) { "dropLayer from \(layers.count)-layer net, at \(dropPoint)" }
        }

        return toMutate
    }

    static func newLayersFromScratch() -> [Int] { Net.layersTemplate }
}
