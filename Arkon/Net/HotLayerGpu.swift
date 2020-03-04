import MetalPerformanceShaders

class HotLayerGpu {
    let adder: MPSMatrixSum
    let biasesMatrix: MPSMatrix
    weak var device: MTLDevice!
    let multiplier: MPSMatrixMultiplication
    let neuronsInMatrix: MPSMatrix
    let neuronsOutMatrix: MPSMatrix
    let transferMatrix: MPSMatrix
    let weightsMatrix: WeightsMatrix

    init(
        _ biases: ArraySlice<Double>,
        _ device: MTLDevice,
        _ neuronsInMatrix: MPSMatrix,
        _ neuronsOutMatrix: MPSMatrix,
        _ weights: ArraySlice<Double>
    ) {
        self.neuronsInMatrix = neuronsInMatrix
        self.neuronsOutMatrix = neuronsOutMatrix

        self.biasesMatrix = HotNetGpu.makeMatrix(device, biases)

        let cNeuronsIn = neuronsInMatrix.columns
        let cNeuronsOut = neuronsOutMatrix.columns
        let cRowsOut = cNeuronsIn

        self.transferMatrix = HotNetGpu.makeMatrix(device, cNeuronsOut)

        self.weightsMatrix = WeightsMatrix(cRowsOut, cNeuronsOut, device, weights)

        adder = MPSMatrixSum(
            device: device, count: 2, rows: 1, columns: cNeuronsOut, transpose: false
        )

        multiplier = MPSMatrixMultiplication(
            device: device, transposeLeft: false, transposeRight: false, resultRows: 1,
            resultColumns: cNeuronsOut, interiorColumns: cRowsOut,
            alpha: 1, beta: 0
        )
    }
}

extension HotLayerGpu {
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

extension HotLayerGpu {

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
