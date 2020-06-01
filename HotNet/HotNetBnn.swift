import Accelerate
import QuartzCore

typealias BnnNumber = Float
let BnnNumberSize: Int = MemoryLayout<BnnNumber>.stride

final class HotNetBnn: HotNet {
    let layerDescriptors: [Int]
    var bnnLayers = [HotLayerBnn]()

    init(
        _ netStructure: NetStructure,
        _ pNeurons_: UnsafePointer<BnnNumber>,
        _ pBiases_: UnsafePointer<BnnNumber>,
        _ pWeights_: UnsafePointer<BnnNumber>
    ) {
        self.layerDescriptors = netStructure.layerDescriptors

        var pNeuronsIn = pNeurons_
        var pNeuronsOut = UnsafeMutablePointer(mutating: pNeurons_ + layerDescriptors[0])
        var pBiases = pBiases_
        var pWeights = pWeights_

        // Connect each upper layer to the lower layer
        bnnLayers = zip(
            netStructure.layerDescriptors.dropLast(),
            netStructure.layerDescriptors.dropFirst()
        ).map {
            cNeuronsIn, cNeuronsOut in

            defer {
                pNeuronsIn  += cNeuronsIn
                pNeuronsOut += cNeuronsOut
                pBiases += cNeuronsOut
                pWeights += (cNeuronsIn * cNeuronsOut)
            }

            return HotLayerBnn(
                cNeuronsIn, pNeuronsIn, pBiases, pWeights, cNeuronsOut, pNeuronsOut
            )
        }
    }

    func driveSignal(_ onComplete: @escaping () -> Void) {
        bnnLayers.forEach { $0.driveSignal() }
        onComplete()
    }

    func release() { bnnLayers.forEach { $0.release() } }

    private func showLayerOutput(_ layerCategory: String, _ output: UnsafeBufferPointer<BnnNumber>) {
        Debug.log(level: 151) {
            var outputString = ""
            var sep = ""

            Array(output).forEach {
                outputString += sep + String(format: "% 0.4f", $0)
                if sep.isEmpty { sep = ", " }
            }

            return "\(layerCategory) layer inputs \(outputString)"
        }
    }

}
