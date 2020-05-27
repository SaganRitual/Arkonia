import CoreGraphics
import Dispatch

enum HotNetType { case blas, bnn, cnn, gpu }
var hotNetType: HotNetType = .bnn

protocol HotNet: class {
    init(
        _ netStructure: NetStructure,
        _ neurons: UnsafeMutablePointer<Float>,
        _ netParameters: UnsafePointer<Float>
    )

    func driveSignal(_ onComplete: @escaping () -> Void)
}

typealias NetParametersBuffer = UnsafeMutableBufferPointer<Float>

class Net {
    static let dispatchQueue = DispatchQueue(
        label: "ak.net.q",
        attributes: .concurrent,
        target: DispatchQueue.global()
    )

    let isCloneOfParent: Bool
    let hotNet: HotNet
    let netParameters: [Float]
    let netStructure: NetStructure
    var neurons: [Float]

    static func makeNet(
        parentNetStructure: NetStructure?,
        parentNetParameters: UnsafePointer<Float>?,
        _ onComplete: @escaping (Net) -> Void
    ) {
        self.dispatchQueue.async {
            let netStructure = NetStructure.makeNetStructure(parentNetStructure)
            let newNet = Net(netStructure, parentNetParameters)
            Dispatch.dispatchQueue.async { onComplete(newNet) }
        }
    }

    private init(
        _ netStructure: NetStructure, _ parentNetParameters: UnsafePointer<Float>?
    ) {
        self.netStructure = netStructure
        self.netParameters = [Float](repeating: 0, count: netStructure.cNetParameters)
        self.neurons = [Float](repeating: 0, count: netStructure.cNeurons)

        if let original = parentNetParameters {
            let copy = UnsafeMutablePointer(mutating: &self.netParameters)
            self.isCloneOfParent = Mutator.mutateNetParameters(
                from: original, to: copy, count: netStructure.cNetParameters
            )
        } else {
            let newParameters = UnsafeMutablePointer(mutating: &self.netParameters)
            (0..<netStructure.cNetParameters).forEach {
                newParameters[$0] = Float.random(in: -1..<1)
            }

            self.isCloneOfParent = false
        }

        let pNeurons = UnsafeMutablePointer(mutating: &self.neurons)
        let pNetParameters = UnsafePointer(self.netParameters)

        switch hotNetType {
        case .bnn:  hotNet = HotNetBnn(netStructure, pNeurons, pNetParameters)
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

    func driveSignal(_ onComplete: @escaping () -> Void) { hotNet.driveSignal(onComplete) }
}
