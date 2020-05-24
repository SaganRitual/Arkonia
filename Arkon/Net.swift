import CoreGraphics
import Dispatch

enum HotNetType { case blas, bnn, cnn, gpu }
var hotNetType: HotNetType = .bnn

protocol HotNet: class {
    init(_ netStructure: NetStructure, _ biases: UnsafeRawPointer, _ weights: UnsafeRawPointer)
    func driveSignal(_ sensoryInputs: [Double], _ onComplete: @escaping ([Double]) -> Void)
}

class Net {
    static let dispatchQueue = DispatchQueue(
        label: "ak.net.q",
        attributes: .concurrent,
        target: DispatchQueue.global()
    )

    let biases: [Float]
    var isCloneOfParent = true
    let hotNet: HotNet
    let netStructure: NetStructure
    let weights: [Float]

    static func makeNet(
        parentNetStructure: NetStructure?,
        parentBiases: [Float]?, parentWeights: [Float]?,
        _ onComplete: @escaping (Net) -> Void
    ) {
        self.dispatchQueue.async {
            let netStructure = NetStructure.makeNetStructure(parentNetStructure)
            let newNet = Net(netStructure, parentBiases, parentWeights)
            Dispatch.dispatchQueue.async { onComplete(newNet) }
        }
    }

    private init(
        _ netStructure: NetStructure, _ parentBiases: [Float]?,
        _ parentWeights: [Float]?
    ) {
        self.netStructure = netStructure

        let biasesStrandRaw = Mutator.mutateNetStrand(
            parentStrand: parentBiases, targetLength: netStructure.cBiases
        )

        self.biases = netStructure.assembleStrand(biasesStrandRaw, 1)

        let weightsStrandRaw = Mutator.mutateNetStrand(
            parentStrand: parentWeights, targetLength: netStructure.cWeights
        )

        self.weights = netStructure.assembleStrand(weightsStrandRaw, 2)

        switch hotNetType {
//        case .blas: hotNet = HotNetBlas(self.layers, self.biases, self.weights)
        case .bnn:  hotNet = HotNetBnn(netStructure, biases, weights)
//        case .cnn:  hotNet = HotNetCnn(self.layers, self.biases, self.weights)
//        case .gpu:  hotNet = HotNetGpu(self.layers, self.biases, self.weights)
        default: fatalError()
        }

        Debug.log(level: 184) { "New net structure \(self.netStructure)" }
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
