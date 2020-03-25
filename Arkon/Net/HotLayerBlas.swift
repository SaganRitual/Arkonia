import Accelerate

class HotLayerBlas {
    var biases = [BlasNumber]()
    var neuronsOut = [BlasNumber]()
    var weights = [BlasNumber]()

    var pBiases: BlasBuffer_Read!
    var pNeuronsOut: BlasBuffer_Write!
    var pWeights: BlasBuffer_Read!

    let cNeuronsIn: Int
    let cNeuronsOut: Int

    init(
        _ biases_: ArraySlice<Double>,
        _ cNeuronsIn: Int,
        _ cNeuronsOut: Int,
        _ weights_: ArraySlice<Double>
    ) {
        self.cNeuronsIn = cNeuronsIn
        self.cNeuronsOut = cNeuronsOut

        self.biases = biases_.prefix(cNeuronsOut).map { BlasNumber($0) }
        self.weights = weights_.prefix(cNeuronsIn * cNeuronsOut).map { BlasNumber($0) }

        self.biases.withUnsafeBufferPointer { self.pBiases = $0 }
        self.weights.withUnsafeBufferPointer { self.pWeights = $0 }
    }

    func driveSignal(_ liveInput: BlasBuffer_Read) -> BlasBuffer_Write {
        self.neuronsOut = self.biases.map { $0 }
        self.neuronsOut.withUnsafeMutableBufferPointer { self.pNeuronsOut = $0 }
        Debug.log(level: 145) { "biases \(self.neuronsOut)" }

        let M: Int32 = 1, K = Int32(liveInput.count), N = Int32(cNeuronsOut)

        cblas_sgemm(
            CblasRowMajor, CblasNoTrans, CblasNoTrans,
            M, N, K,
            1, liveInput.baseAddress,
            K, pWeights.baseAddress, N,
            1, pNeuronsOut.baseAddress, N
        )

        (0..<self.neuronsOut.count).forEach {
            let a = Double(self.neuronsOut[$0])
            let b = Net.logistic(a)
            let c = BlasNumber(b)
            self.neuronsOut[$0] = c
        }

        Debug.log(level: 145) { "weights \(self.weights)" }
        Debug.log(level: 145) { "outputs \(self.neuronsOut)" }
        return pNeuronsOut
    }
}

extension HotLayerBlas {

    func getComputeOutput() -> [Double] { neuronsOut.map { Double($0) } }

    func getOutputBuffer() -> BlasBuffer_Read {
        var buffer: BlasBuffer_Read!
        neuronsOut.withUnsafeBufferPointer { buffer = $0 }
        return buffer
    }

    func showComputeOutput() {
//        var output = getComputeOutput(transferMatrix)
//        print("transfer", output)

//        let output = getComputeOutput(neuronsOutMatrix)
//        print("neuronsOut", output)
    }
}
