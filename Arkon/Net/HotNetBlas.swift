import Accelerate
import QuartzCore

typealias BlasNumber = Float
typealias BlasBuffer_Read = UnsafeBufferPointer<BlasNumber>
typealias BlasBuffer_Write = UnsafeMutableBufferPointer<BlasNumber>

final class HotNetBlas: HotNet {
    var activator: (Double) -> Double
    var blasLayers = [HotLayerBlas]()
    var neuronsOut = [BlasNumber]()

    init(_ coldLayers: [Int], _ biases: [Double], _ weights: [Double], _ activator: @escaping (Double) -> Double) {
        self.activator = activator

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

    func driveSignal(
        _ sensoryInputs: [Double], _ onComplete: @escaping ([Double]) -> Void
    ) {
        let si = sensoryInputs.map { BlasNumber($0) }

        si.withUnsafeBufferPointer {
            var inputToNextLayer = $0
            var outputs: BlasBuffer_Write!

            blasLayers.forEach { layer in
                Debug.log(level: 122) { "driveSignal out \(Array(inputToNextLayer))" }
                outputs = layer.driveSignal(inputToNextLayer)
                outputs.withUnsafeBufferPointer { inputToNextLayer = $0 }
            }

            let oc = Array(inputToNextLayer).map { activator(Double($0)) }
            onComplete(oc)
        }
    }

}
