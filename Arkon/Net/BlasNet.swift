import Accelerate
import QuartzCore

typealias BlasNumber = Float
typealias BlasBuffer_Read = UnsafeBufferPointer<BlasNumber>
typealias BlasBuffer_Write = UnsafeMutableBufferPointer<BlasNumber>

class BlasNet {
    var blasLayers = [BlasLayer]()
    var neuronsOut = [BlasNumber]()

    init(_ coldLayers: [Int], _ biases_: [Double], _ weights: [Double]) {
        let CL = coldLayers + [Arkonia.cMotorNeurons]

        let biases = biases_[...]   // Get slice thingy

        blasLayers = zip(0..<CL.count - 1, 1..<CL.count).map { upperLayerIx, lowerLayerIx in
            let cNeuronsIn = CL[upperLayerIx]
            let cNeuronsOut = CL[lowerLayerIx]
            let layerBiases = biases.dropFirst(cNeuronsOut)
            let layerWeights = weights.dropFirst(cNeuronsIn * cNeuronsOut)
            return BlasLayer(layerBiases, cNeuronsIn, cNeuronsOut, layerWeights)
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
                outputs = layer.driveSignal(inputToNextLayer)
                outputs.withUnsafeBufferPointer { inputToNextLayer = $0 }
            }

            onComplete(Array(inputToNextLayer).map { Double($0) })
        }
    }

}
