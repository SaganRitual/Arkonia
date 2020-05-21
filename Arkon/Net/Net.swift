import CoreGraphics
import Dispatch

enum HotNetType { case blas, bnn, cnn, gpu }
var hotNetType: HotNetType = .bnn

protocol HotNet: class {
    init(_ layers: [Int], _ biases: [Double], _ weights: [Double])
    func driveSignal(_ sensoryInputs: [Double], _ onComplete: @escaping ([Double]) -> Void)
}

class Net {
    static let dispatchQueue = DispatchQueue(
        label: "ak.net.q",
        attributes: .concurrent,
        target: DispatchQueue.global()
    )

    let biases: [Double]
    let cBiases: Int
    let cNeurons: Int
    let cWeights: Int
    var isCloneOfParent = true
    let hotNet: HotNet
    let layers: [Int]
    let weights: [Double]

    static func makeNet(
        parentBiases: [Double]?, parentWeights: [Double]?, layers: [Int]?,
        _ onComplete: @escaping (Net) -> Void
    ) {
        self.dispatchQueue.async {
            let newNet = Net(parentBiases, parentWeights, layers)
            Dispatch.dispatchQueue.async { onComplete(newNet) }
        }
    }

    static func generateRandomNetStructure() -> [Int] {
        var L = [Int]()

        // Just making stuff up here
        let div = Arkonia.random(in: 2...4)
        var cNeurons = Arkonia.cSenseNeurons
        while cNeurons > (div * Arkonia.cMotorNeurons) {
            L.append(cNeurons)
            cNeurons /= div
        }

        L.append(Arkonia.cMotorNeurons)

        return L
    }

    private init(
        _ parentBiases: [Double]?, _ parentWeights: [Double]?, _ layers: [Int]?
    ) {
        var didMutate = false

        if let L = layers {
            (self.layers, didMutate) = Mutator.mutateNetStructure(L)
        } else {
            self.layers = Net.generateRandomNetStructure()
        }

        self.cNeurons = self.layers.reduce(0, +)

        (cWeights, cBiases) = Net.computeParameters(self.layers)

        var dm = false
        (self.biases, didMutate) = Mutator.mutateNetStrand(parentStrand: parentBiases, targetLength: cBiases)
        if didMutate { dm = true }
        (self.weights, didMutate) = Mutator.mutateNetStrand(parentStrand: parentWeights, targetLength: cWeights)
        if didMutate { dm = true }

        self.isCloneOfParent = !dm

        switch hotNetType {
        case .blas: hotNet = HotNetBlas(self.layers, self.biases, self.weights)
        case .bnn:  hotNet = HotNetBnn(self.layers, self.biases, self.weights)
        case .cnn:  hotNet = HotNetCnn(self.layers, self.biases, self.weights)
        case .gpu:  hotNet = HotNetGpu(self.layers, self.biases, self.weights)
        }

        Debug.log(level: 155) { "New net \(self.layers.count) layers \(self.cNeurons) neurons" }
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
    static func identity(_ x: Double) -> Double { x }
    static func leakyrelu(_ x: Double) -> Double { x < 0.0 ? (0.01 * x) : x }

    static func logistic(_ x: Double) -> Double { 1.0 / (1.0 + exp(-x)) }

    static func sinusoid(_ x: Double) -> Double { sin(x) }

    static func sqnl(_ x: Double) -> Double {
        switch x {
        case -2.0..<0.0: return x + x * x / 4.0
        case 0.0..<2.0:  return x - x * x / 4.0
        case 2.0...:     return 0.99
        default:         return -1.0
        }
    }

    static let funcs = [
        arctan, bentidentity, identity, leakyrelu, sinusoid, sqnl
    ]

    func getMotorOutputs(_ sensoryInputs: [Double], _ onComplete: @escaping ([Double]) -> Void) {
        hotNet.driveSignal(sensoryInputs, onComplete)
    }
}
