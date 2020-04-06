import Accelerate
import QuartzCore

typealias BnnNumber = Float

final class HotNetBnn: HotNet {
    var bnnLayers = [HotLayerBnn]()
    var neuronsIn: [BnnNumber]

    init(_ coldLayers: [Int], _ biases: [Double], _ weights: [Double]) {
        let CL = coldLayers// + [Arkonia.cMotorNeurons]

        var biasesIxL = 0, biasesIxR = 0
        var weightsIxL = 0, weightsIxR = 0

        // Input to top layer
        self.neuronsIn = [BnnNumber](repeating: 0, count: CL[0])
        var nextInput = UnsafePointer(self.neuronsIn)

        bnnLayers = zip(0..<CL.count - 1, 1..<CL.count).map { upperLayerIx, lowerLayerIx in
            let cNeuronsIn = CL[upperLayerIx]
            let cNeuronsOut = CL[lowerLayerIx]

            biasesIxR += cNeuronsOut
            weightsIxR += cNeuronsIn * cNeuronsOut

            let layerBiases = biases[biasesIxL..<biasesIxR]
            let layerWeights = weights[weightsIxL..<weightsIxR]

            let h = HotLayerBnn(layerBiases, nextInput, cNeuronsIn, cNeuronsOut, layerWeights)
            nextInput = h.getOutputBuffer()
            return h
        }
    }

    func driveSignal(
        _ sensoryInputs: [Double], _ onComplete: @escaping ([Double]) -> Void
    ) {
        let si = sensoryInputs.map { BnnNumber($0) }
        assert(sensoryInputs.min()! >= -1 && sensoryInputs.max()! <= 1)

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
