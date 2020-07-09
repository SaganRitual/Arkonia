import MetalPerformanceShaders

class HotLayerMps {
    let commandBuffer: MTLCommandBuffer
    let copier: MPSMatrixCopy
    let copyDescriptor: MPSMatrixCopyDescriptor
    let multiplier: MPSMatrixMultiplication
    let mxBiases: MPSMatrix
    let mxNeuronsIn: MPSMatrix?
    let mxNeuronsOut: MPSMatrix?
    let mxWeights: MPSMatrix

    let neuronsIn_: UnsafeMutableRawPointer, neuronsIn: UnsafeMutablePointer<Float>

    init(
        _ device: MTLDevice,
        _ cNeuronsIn: Int,
        _ cNeuronsOut: Int,
        _ mxNeuronsIn: AKMatrix<Float>?,
        _ mxNeuronsOut: AKMatrix<Float>?,
        _ pBiases: UnsafePointer<Float>,
        _ pWeights: UnsafePointer<Float>
    ) {
        let cq = device.makeCommandQueue()
        self.commandBuffer = cq!.makeCommandBuffer()!

        self.mxBiases = HotLayerMps.setupMatrix(device, pBiases, cRows: 1, cColumns: cNeuronsOut)
        self.mxWeights = HotLayerMps.setupMatrix(device, pWeights, cRows: cNeuronsIn, cColumns: cNeuronsOut)

        self.mxNeuronsIn = HotLayerMps.setupMatrix(device, cRows: 1, cColumns: cNeuronsIn)
        self.mxNeuronsOut = HotLayerMps.setupMatrix(device, cRows: 1, cColumns: cNeuronsOut)

        self.copier = .init(
            device: device, copyRows: 1, copyColumns: cNeuronsOut,
            sourcesAreTransposed: false, destinationsAreTransposed: false
        )

        self.copyDescriptor = .init(
            sourceMatrix: mxBiases, destinationMatrix: mxNeuronsOut,
            offsets: MPSMatrixCopyOffsets()
        )

        self.multiplier = .init(
            device: device, transposeLeft: false, transposeRight: false, resultRows: 1,
            resultColumns: cNeuronsOut, interiorColumns: cNeuronsIn,
            alpha: 1, beta: 1
        )
    }

    deinit {
        neuronsIn_.deallocate()
    }
}

extension HotLayerMps {
    func driveSignal(_ onComplete: @escaping (MTLCommandBuffer) -> Void) {
        copier.encode(commandBuffer: commandBuffer, copyDescriptor: copyDescriptor)

        multiplier.encode(
            commandBuffer: commandBuffer,
            leftMatrix: mxNeuronsIn,
            rightMatrix: mxWeights,
            resultMatrix: mxNeuronsOut
        )

        commandBuffer.addCompletedHandler(onComplete)
        commandBuffer.commit()
    }
}

private extension HotLayerMps {
    static func setupMatrix(
        _ device: MTLDevice, _ pData: UnsafePointer<Float>, cRows: Int, cColumns: Int
    ) -> MPSMatrix {
        let length = align4k(cRows * cColumns * NumberSize)
        let mp = UnsafeMutablePointer(mutating: pData)
        let db = device.makeBuffer(
            bytesNoCopy: mp, length: length, options: .storageModeShared
        )

        let md = MPSMatrixDescriptor(
            dimensions: cRows, columns: cColumns,
            rowBytes: cColumns * NumberSize, dataType: NumberTypeInGPU
        )

        return MPSMatrix(buffer: db!, descriptor: md)
    }

//    static func setupMatrix(
//        _ device: MTLDevice, cRows: Int, cColumns: Int
//    ) -> MPSMatrix {
//        let length = align4k(cRows * cColumns * NumberSize)
//        let (raw_, raw) = Net.allocateBuffer(cBytes: length)
//
//        let db = device.makeBuffer(
//            bytesNoCopy: raw, length: length, options: .storageModeShared
//        )
//
//        let md = MPSMatrixDescriptor(
//            dimensions: cRows, columns: cColumns,
//            rowBytes: cColumns * NumberSize, dataType: NumberTypeInGPU
//        )
//
//        return MPSMatrix(buffer: db!, descriptor: md)
//    }
}
