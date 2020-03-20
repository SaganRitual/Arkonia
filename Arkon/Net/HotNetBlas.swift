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

    // extra to allow for == 1
    static var inputsHistogram = [Double](repeating: 0, count: 10)
    static var gridInputsHistogram = [Double](repeating: 0, count: 10)

    func driveSignal(
        _ sensoryInputs: [Double], _ onComplete: @escaping ([Double]) -> Void
    ) {
        let si = sensoryInputs.map { BlasNumber($0) }
//        Debug.log(level: 138) { "driveSignal in \(sensoryInputs)" }
        assert(sensoryInputs.min()! >= -1 && sensoryInputs.max()! <= 1)

        Debug.log(level: 142) {

            sensoryInputs.forEach {
                let scaledUp = ($0 + 1) * Double(HotNetBlas.inputsHistogram.count) / 2
                let truncated = Int(ceil(scaledUp)) - 1
                if truncated >= HotNetBlas.inputsHistogram.count { print("here \(truncated)") }
                HotNetBlas.inputsHistogram[truncated] += 1
            }

            return "sihist \(HotNetBlas.inputsHistogram)"
        }

        si.withUnsafeBufferPointer {
            var inputToNextLayer = $0
            var outputs: BlasBuffer_Write!

            Debug.log(level: 143) { "1.driveSignal out \(Array(inputToNextLayer))" }

            blasLayers.forEach { layer in
                outputs = layer.driveSignal(inputToNextLayer)
                outputs.withUnsafeBufferPointer { inputToNextLayer = $0 }
                Debug.log(level: 143) { "n.driveSignal out \(Array(inputToNextLayer))" }
            }

            let oc = Array(inputToNextLayer).map { Double($0) }
            onComplete(oc)
        }
    }

}
