import Accelerate
import QuartzCore

typealias BnnNumber = Float
let BnnNumberSize: Int = MemoryLayout<BnnNumber>.stride

final class HotNetBnn: HotNet {
    var bnnLayers = [HotLayerBnn]()
    var neuronsIn: [BnnNumber]

    init(_ coldLayers: [Int], _ biases: UnsafeRawPointer, _ weights: UnsafeRawPointer) {
        var biasesIx = 0
        var weightsIx = 0

        // Input to top layer
        self.neuronsIn = [BnnNumber](repeating: 0, count: coldLayers[0])
        var nextInput = UnsafePointer(self.neuronsIn)

        bnnLayers = zip(0..<coldLayers.count - 1, 1..<coldLayers.count).map { upperLayerIx, lowerLayerIx in
            let cNeuronsIn = coldLayers[upperLayerIx]
            let cNeuronsOut = coldLayers[lowerLayerIx]

            let layerBiases = biases.advanced(by: biasesIx * BnnNumberSize)
            let layerWeights = weights.advanced(by: weightsIx * BnnNumberSize)

            biasesIx += cNeuronsOut
            weightsIx += cNeuronsIn * cNeuronsOut

            let h = HotLayerBnn(layerBiases, nextInput, cNeuronsIn, cNeuronsOut, layerWeights)
            nextInput = h.getOutputBuffer()
            return h
        }
    }

    func driveSignal(
        _ sensoryInputs: [Double], _ onComplete: @escaping ([Double]) -> Void
    ) {
        let si = sensoryInputs.map { BnnNumber($0) }
        hardAssert(sensoryInputs.min()! >= -1 && sensoryInputs.max()! <= 1, "hardAssert at \(#file):\(#line)")

        bnnLayers.first!.driveSignal(si)

        bnnLayers.dropFirst().forEach { $0.driveSignal() }

        let finalOutput = bnnLayers.last!.getOutputBuffer()
        let oc = (0..<bnnLayers.last!.neuronsOut.count).map { Double(finalOutput.advanced(by: $0).pointee) }

        onComplete(oc)
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
