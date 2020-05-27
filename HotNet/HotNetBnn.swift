import Accelerate
import QuartzCore

typealias BnnNumber = Float
let BnnNumberSize: Int = MemoryLayout<BnnNumber>.stride

final class HotNetBnn: HotNet {
    let layerDescriptors: ArraySlice<Int>
    var bnnLayers = [HotLayerBnn]()

    init(
        _ netStructure: NetStructure,
        _ neurons: UnsafeMutablePointer<Float>,
        _ netParameters: UnsafePointer<Float>
    ) {
        self.layerDescriptors = netStructure.layerDescriptors

        var neuronsIx = 0
        var biasesIx = 0
        var weightsIx = 0

        let biases_ = UnsafeBufferPointer(start: netParameters, count: netStructure.cNetParameters)
        let weights_ = UnsafeBufferPointer(start: netParameters, count: netStructure.cNetParameters)

        // Connect each upper layer to the lower layer
        bnnLayers = zip(
            netStructure.layerDescriptors.dropLast(),
            netStructure.layerDescriptors.dropFirst()
        ).map {
            cNeuronsIn, cNeuronsOut in

            let neuronsIn = withUnsafePointer(to: &neurons[neuronsIx]) { $0 }

            let neuronsOutOffset = neuronsIx + cNeuronsIn
            let neuronsOut = withUnsafeMutablePointer(to: &neurons[neuronsOutOffset]) { $0 }

            let biases = withUnsafePointer(to: biases_[biasesIx]) { $0 }

            neuronsIx += neuronsOutOffset + cNeuronsOut

            weightsIx = biasesIx  + cNeuronsOut
            biasesIx  = weightsIx + cNeuronsOut * cNeuronsIn

            let weights = withUnsafePointer(to: weights_[weightsIx]) { $0 }

            return HotLayerBnn(cNeuronsIn, neuronsIn, biases, weights, cNeuronsOut, neuronsOut)
        }
    }

    func driveSignal(_ onComplete: @escaping () -> Void) {
        bnnLayers.forEach { $0.driveSignal() }
        onComplete()
    }

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
