import Accelerate
import QuartzCore

typealias BlasNumber = Float
typealias BlasBuffer_Read = UnsafeBufferPointer<BlasNumber>
typealias BlasBuffer_Write = UnsafeMutableBufferPointer<BlasNumber>

final class HotNetBlas: HotNet {
    var blasLayers = [HotLayerBlas]()
    var neuronsOut = [BlasNumber]()

    init(_ coldLayers: [Int], _ biases: [Double], _ weights: [Double]) {
        let CL = coldLayers// + [Arkonia.cMotorNeurons]

        var biasesIxL = 0, biasesIxR = 0
        var weightsIxL = 0, weightsIxR = 0

        blasLayers = zip(0..<CL.count - 1, 1..<CL.count).map { upperLayerIx, lowerLayerIx in
            let cNeuronsIn = CL[upperLayerIx]
            let cNeuronsOut = CL[lowerLayerIx]

            biasesIxR += cNeuronsOut
            weightsIxR += cNeuronsIn * cNeuronsOut

            let layerBiases = biases[biasesIxL..<biasesIxR]
            let layerWeights = weights[weightsIxL..<weightsIxR]

            return HotLayerBlas(layerBiases, cNeuronsIn, cNeuronsOut, layerWeights)
        }
    }

    // extra to allow for == 1
    static var inputsHistogram = [Double](repeating: 0, count: 10)
    static var gridInputsHistogram = [Double](repeating: 0, count: 10)

    func driveSignal(
        _ sensoryInputs: [Double], _ onComplete: @escaping ([Double]) -> Void
    ) {
        let si = sensoryInputs.map { BlasNumber($0) }
        assert(sensoryInputs.min()! >= -1 && sensoryInputs.max()! <= 1)

        si.withUnsafeBufferPointer {
            var inputToNextLayer = $0
            var outputs: BlasBuffer_Write!

            showLayerOutput("top   ", inputToNextLayer)

            blasLayers.forEach { layer in
                outputs = layer.driveSignal(inputToNextLayer)
                outputs.withUnsafeBufferPointer { inputToNextLayer = $0 }
                showLayerOutput("hidden", inputToNextLayer)
            }

            let oc = Array(inputToNextLayer).map { Double($0) }

            onComplete(oc)
        }
    }

    private func showLayerOutput(_ layerCategory: String, _ output: UnsafeBufferPointer<BlasNumber>) {
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
