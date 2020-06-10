import Accelerate
import QuartzCore

final class HotNetBlas: HotNet {
    var blasLayers = [HotLayerBlas]()

    init(
        _ netStructure: NetStructure,
        _ pNeurons_: UnsafePointer<Float>,
        _ pBiases_: UnsafePointer<Float>,
        _ pWeights_: UnsafePointer<Float>
    ) {
        let dd = netStructure.layerDescriptors

        var pNeuronsIn = pNeurons_
        var pNeuronsOut = UnsafeMutablePointer(mutating: pNeurons_ + dd[0])
        var pBiases = pBiases_
        var pWeights = pWeights_

        // Connect each upper layer to the lower layer
        blasLayers = zip(dd.dropLast(), dd.dropFirst()).map {
            cNeuronsIn, cNeuronsOut in

            defer {
                pNeuronsIn  =  UnsafePointer(pNeuronsOut)   // Output from one layer is input to next
                pNeuronsOut += cNeuronsOut
                pBiases     += cNeuronsOut
                pWeights    += (cNeuronsIn * cNeuronsOut)
            }

            return HotLayerBlas(
                cNeuronsIn, pNeuronsIn, pBiases, pWeights, cNeuronsOut, pNeuronsOut
            )
        }
    }

    func driveSignal(_ onComplete: @escaping () -> Void) {
        blasLayers.forEach { $0.driveSignal() }

        let c = blasLayers.last!.cNeuronsOut
        let p = blasLayers.last!.pNeuronsOut
        let log = (0..<c).map { p[$0] }
        Debug.log(level: 193) { "motorOutputs \(log)" }
        onComplete()
    }

    func release() {} // Required by protocol
}
