import MetalPerformanceShaders

class WeightsMatrix {
    let cColumnsIn: Int
    let cColumnsOut: Int
    var cRowsOut: Int { cColumnsIn }
    let device: MTLDevice
    let mpsMatrix: MPSMatrix
    let rowStride: Int

    init(_ cColumnsIn: Int, _ cColumnsOut: Int, _ device: MTLDevice, _ weightsRaw: ArraySlice<Double>) {
        self.cColumnsIn = cColumnsIn
        self.cColumnsOut = cColumnsOut
        self.device = device

        self.rowStride = MPSMatrixDescriptor.rowBytes(fromColumns: cColumnsOut, dataType: NumberTypeInGPU)

        let cRowsOut = cColumnsIn
        let matrixDescriptor = MPSMatrixDescriptor(
            dimensions: cRowsOut, columns: cColumnsOut,
            rowBytes: rowStride, dataType: NumberTypeInGPU
        )

        let mb = (device.makeBuffer(
            length: matrixDescriptor.matrixBytes,
            options: MTLResourceOptions.storageModeManaged
        ))!

        mpsMatrix = MPSMatrix(buffer: mb, descriptor: matrixDescriptor)

        var rowStartIx = weightsRaw.startIndex
        let as2dArray: [[Double]] = (0..<cRowsOut).map { _ in
            let rowEndIx = weightsRaw.index(rowStartIx, offsetBy: cColumnsOut)

            defer { rowStartIx = rowEndIx }
            return Array(weightsRaw[rowStartIx..<rowEndIx])
        }

        fillMatrix(as2dArray)
    }

    func fillMatrix(_ weightsRaw: [[Double]]) {
        (0..<cRowsOut).forEach { inputWeightsRowIx in fillRow(inputWeightsRowIx, weightsRaw) }
    }

    func fillRow(_ inputWeightsRowIx: Int, _ weightsRaw: [[Double]]) {
        (0..<cColumnsOut).forEach { inputWeightsColumnIx in
            let outputRowOffset = inputWeightsRowIx * rowStride
            let outputColumnOffset = inputWeightsColumnIx * NumberSize
            let outputByteOffset = outputRowOffset + outputColumnOffset

            let weight = Number(weightsRaw[inputWeightsRowIx][inputWeightsColumnIx])

            let c = self.mpsMatrix.data.contents()
            c.storeBytes(of: weight, toByteOffset: outputByteOffset, as: Number.self)
        }
    }
}
