import MetalPerformanceShaders

class HotLayerCnn {
    var biases: [Number]
    var pBiases: UnsafeMutablePointer<Float>
    let convolutionDescriptor: MPSCNNConvolutionDescriptor
    weak var device: MTLDevice!
    var pTheWeightsArray: UnsafeMutableRawPointer
    let theWeightsArray: [Number]

    init(
        _ biases: ArraySlice<Double>,
        _ cNeuronsIn: Int,
        _ cNeuronsOut: Int,
        _ device: MTLDevice,
        _ weights: ArraySlice<Double>
    ) {
        self.biases = biases.map { Number($0) }
        biases.withUnsafeMutableBufferPointer { pBiases = $0 }

        self.theWeightsArray = weights.map { Number($0) }
        self.pTheWeightsArray = UnsafeMutableRawPointer.allocate(
            byteCount: weights.count * NumberSize, alignment: NumberSize
        )

        let cRowsIn = 1
        let cRowsOut = cNeuronsIn

        convolutionDescriptor = MPSCNNConvolutionDescriptor(
            kernelWidth: 1, kernelHeight: 1, inputFeatureChannels: cRowsIn,
            outputFeatureChannels: cNeuronsOut, neuronFilter: nil
        )

        let fc = MPSCNNFullyConnected(
            device: device, convolutionDescriptor: fcDesc,
            kernelWeights: weights.map { Float($0) }, biasTerms: biases.map { Float($0) },
            flags: .none
        )
    }
}

extension HotLayerCnn: NSObject,   {

    func biasTerms() -> UnsafeMutablePointer<Float>? { pBiases }

    func dataType() -> MPSDataType { NumberTypeInGPU }

    func descriptor() -> MPSCNNConvolutionDescriptor { convolutionDescriptor }

    func label() -> String? { nil }

    func load() -> Bool { false }

    func purge() { assert(false) }

    func weights() -> UnsafeMutableRawPointer { pTheWeightsArray }
}

extension HotLayerCnn {
    func showComputeOutput() {
//        var output = getComputeOutput(transferMatrix)
//        print("transfer", output)

//        let output = getComputeOutput(neuronsOutMatrix)
//        print("neuronsOut", output)
    }

    func getComputeOutput(_ matrix: MPSMatrix? = nil) -> [Double] {
        let matrix = matrix ?? neuronsOutMatrix

        let rc = matrix.data.contents()
        return stride(from: 0, to: matrix.columns * NumberSize, by: NumberSize).map {
            offset in

            let rr = rc.load(fromByteOffset: offset, as: Number.self)

            return Net.sinusoid(Double(rr))
        }
    }
}

extension HotLayerCnn {

    func chargeCommandBuffer(_ commandBuffer: MTLCommandBuffer) {
        multiplier.encode(
            commandBuffer: commandBuffer, leftMatrix: neuronsInMatrix,
            rightMatrix: weightsMatrix.mpsMatrix, resultMatrix: transferMatrix
        )

         adder.encode(
            to: commandBuffer,
            sourceMatrices: [transferMatrix, biasesMatrix],
            resultMatrix: neuronsOutMatrix, scale: nil, offsetVector: nil,
            biasVector: nil, start: 0
        )
    }
}
