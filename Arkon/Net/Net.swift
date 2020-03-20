import CoreGraphics
import Dispatch

enum HotNetType { case blas, cnn, gpu }
var hotNetType: HotNetType = .blas

protocol HotNet: class {
    init(_ layers: [Int], _ biases: [Double], _ weights: [Double], _ activator: @escaping (Double) -> Double)
    func driveSignal(_ sensoryInputs: [Double], _ onComplete: @escaping ([Double]) -> Void)
}

class Net {
    static let dispatchQueue = DispatchQueue(
        label: "ak.net.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .utility)
    )

    let activatorFunction: (_: Double) -> Double
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
        var didMutate = false

        if let L = layers {
            (self.layers, didMutate) = Mutator.mutateNetStructure(L)
        } else {
            let L: [Int] = [
                Arkonia.cSenseNeurons,
                Arkonia.cSenseNeurons / 2,
                Arkonia.cSenseNeurons / 4,
                Arkonia.cMotorNeurons
            ]

//            var cNeurons = Arkonia.cSenseNeurons
//            while cNeurons > (2 * Arkonia.cMotorNeurons) {
//                L.append(cNeurons)
//                cNeurons /= 2
//            }
//
//            L.append(2 * Arkonia.cMotorNeurons)
//            L.append(Arkonia.cMotorNeurons)
            self.layers = L
        }

        self.cNeurons = self.layers.reduce(0, +)

        (cWeights, cBiases) = Net.computeParameters(self.layers)

        var dm = false
        (self.biases, didMutate) = Mutator.mutateNetStrand(parentStrand: parentBiases, targetLength: cBiases)
        if didMutate { dm = true }
        (self.weights, didMutate) = Mutator.mutateNetStrand(parentStrand: parentWeights, targetLength: cWeights)
        if didMutate { dm = true }

        (self.activatorFunction, didMutate) = Mutator.mutateActivator(parentActivator: parentActivator)
        if didMutate { dm = true }

        self.isCloneOfParent = !dm

        switch hotNetType {
        case .blas: hotNet = HotNetBlas(self.layers, self.biases, self.weights, self.activatorFunction)
        case .cnn:  hotNet = HotNetCnn(self.layers, self.biases, self.weights, self.activatorFunction)
        case .gpu:  hotNet = HotNetGpu(self.layers, self.biases, self.weights, self.activatorFunction)
        }
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
        case 2.0...:     return 1.0
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
