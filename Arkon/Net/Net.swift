import CoreGraphics
import Dispatch
import MetalPerformanceShaders

enum HotNetType { case blas, bnn, cnn, gpu }
var hotNetType: HotNetType = .blas

typealias Number = Float

let NumberSize = MemoryLayout<Number>.size
let NumberTypeInGPU = MPSDataType.float32

protocol HotNet: class {
    init(
        _ netStructure: NetStructure,
        _ parentNeurons: UnsafePointer<Float>,
        _ parentBiases: UnsafePointer<Float>,
        _ parentWeights: UnsafePointer<Float>
    )

    func driveSignal(_ onComplete: @escaping () -> Void)
    func release()
}

typealias NetParametersBuffer = UnsafeMutableBufferPointer<Float>

class Net {
    let isCloneOfParent: Bool
    let hotNet: HotNet
    let netStructure: NetStructure
    let pBiases: UnsafePointer<Float>
    let pNeurons: UnsafePointer<Float>
    let pWeights: UnsafePointer<Float>

    let pSenseNeuronsGrid: UnsafeMutablePointer<Float>
    let pSenseNeuronsMisc: UnsafeMutablePointer<Float>
    let pSenseNeuronsPollenators: UnsafeMutablePointer<Float>
    let pMotorOutputs: UnsafePointer<Float>

    static func makeNet(
        _ netStructure: NetStructure,
        _ parentBiases: UnsafePointer<Float>?,
        _ parentWeights: UnsafePointer<Float>?,
        _ onComplete: @escaping (Net) -> Void
    ) {
        MainDispatchQueue.async {
            let (pb, pw) = netStructure.isCloneOfParent ?
                (parentBiases, parentWeights) : (nil, nil)

            let newNet = Net(
                netStructure: netStructure, parentBiases: pb, parentWeights: pw
            )

            onComplete(newNet)
        }
    }

    private init(
        netStructure: NetStructure,
        parentBiases: UnsafePointer<Float>?, parentWeights: UnsafePointer<Float>?
    ) {
        self.netStructure = netStructure

        let neurons = UnsafeMutablePointer<Float>.allocate(capacity: netStructure.cNeurons)
        let biases = UnsafeMutablePointer<Float>.allocate(capacity: netStructure.cBiases)
        let weights = UnsafeMutablePointer<Float>.allocate(capacity: netStructure.cWeights)

        neurons.initialize(repeating: 0, count: netStructure.cNeurons)

        Debug.log(level: 187) { "neurons at \(neurons); \(netStructure.cNeurons) floats, \(netStructure.cNeurons * 4) bytes" }
        Debug.log(level: 187) { "biases at \(biases); \(netStructure.cBiases) floats, \(netStructure.cBiases * 4) bytes" }
        Debug.log(level: 187) { "weights at \(weights); \(netStructure.cWeights) floats, \(netStructure.cWeights * 4) bytes" }

        // If the net structure has mutated, the biases and weights are irrelevant;
        // there's no point in trying to use any of them, and the buffers will need
        // to be different sizes anyway. Use all that stuff only if my net structure
        // is a clone of my parent's net structure.
        //
        // If my net structure is a clone of my parent's net structure,
        // copy his buffers and see about mutating the biases and/or
        // weights I'm inheriting
        if netStructure.isCloneOfParent {
            biases.initialize(from: parentBiases!, count: netStructure.cBiases)
            weights.initialize(from: parentWeights!, count: netStructure.cWeights)
            self.isCloneOfParent = Net.mutateNetParameters(
                biases, netStructure.cBiases, weights, netStructure.cWeights
            )
        } else {
            (0..<netStructure.cBiases).forEach  { biases[$0]  = Float.random(in: -1..<1) }
            (0..<netStructure.cWeights).forEach { weights[$0] = Float.random(in: -1..<1) }
            self.isCloneOfParent = false
        }

        // I don't get this. If we init the parameters with random Float values as
        // above, we get arkons that move in straight lines. If we mutate those same
        // values *randomly*, like this, they behave differently. Weird
//        self.isCloneOfParent = Net.mutateNetParameters(
//            biases, netStructure.cBiases, weights, netStructure.cWeights
//        )

        self.pNeurons = UnsafePointer(neurons)
        self.pBiases = UnsafePointer(biases)
        self.pWeights = UnsafePointer(weights)

        self.pSenseNeuronsGrid = UnsafeMutablePointer(mutating: pNeurons + 0)
        self.pSenseNeuronsMisc = pSenseNeuronsGrid + netStructure.cSenseNeuronsGrid
        self.pSenseNeuronsPollenators = pSenseNeuronsMisc + netStructure.cSenseNeuronsMisc

        self.pMotorOutputs = pNeurons + netStructure.cNeurons - netStructure.cMotorNeurons

        hardAssert(
            netStructure.cSenseNeurons == netStructure.cSenseNeuronsGrid
            + netStructure.cSenseNeuronsMisc + netStructure.cSenseNeuronsPollenators
        )  { "\(#file):\(#line)" }

        hardAssert(
            netStructure.cNeurons == netStructure.cSenseNeurons
            + netStructure.cHiddenNeurons + netStructure.cMotorNeurons
        )  { "\(#file):\(#line)" }

        switch hotNetType {
        case .blas: hotNet = HotNetBlas(netStructure, pNeurons, pBiases, pWeights)
        case .bnn:  hotNet = HotNetBnn(netStructure, pNeurons, pBiases, pWeights)
        default: fatalError()
        }
    }

    func release(_ onComplete: @escaping () -> Void) {
        [pNeurons, pBiases, pWeights].forEach { $0.deallocate() }
        onComplete()
    }
}

extension Net {
    static func arctan(_ x: Float) -> Float { atan(x) }
    static func bentidentity(_ x: Float) -> Float { ((sqrt(x * x + 1.0) - 1.0) / 2.0) + x }
    static func identity(_ x: Float) -> Float { x }
    static func leakyrelu(_ x: Float) -> Float { x < 0.0 ? (0.01 * x) : x }

    static func logistic(_ x: Float) -> Float { 1.0 / (1.0 + exp(-x)) }

    static func sinusoid(_ x: Float) -> Float { sin(x) }

    static func sqnl(_ x: Float) -> Float {
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
