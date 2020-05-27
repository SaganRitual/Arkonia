import Foundation
import MetalPerformanceShaders

class HotLayerCnn {
    let biases: [Float]
    let cNeuronsIn: Int
    let cNeuronsOut: Int
    let cnnLayer: MPSCNNFullyConnected
    let dataSource: DataSource
    weak var device: MTLDevice!
    let imageIn: MPSImage
    let imageOut: MPSImage
    let weights: [Float]

    init(
        _ biases: ArraySlice<Double>,
        _ cNeuronsIn: Int,
        _ cNeuronsOut: Int,
        _ device: MTLDevice,
        _ imageIn: MPSImage,
        _ imageOut: MPSImage,
        _ weights: ArraySlice<Double>
    ) {
        self.biases = biases.map { Float($0) }
        self.cNeuronsIn = cNeuronsIn
        self.cNeuronsOut = cNeuronsOut
        self.imageIn = imageIn
        self.imageOut = imageOut

        self.dataSource = DataSource(
            biases, device, "hot.net.cnn.data.source",
            1, 1, cNeuronsIn, cNeuronsOut, weights
        )

        self.device = device
        self.weights = weights.map { Float($0) }

        self.cnnLayer = MPSCNNFullyConnected(device: device, weights: dataSource)
    }

    func chargeLayerInput(_ input_: ArraySlice<Double>) {
        let input = input_.map { Float($0) }

        input.withUnsafeBufferPointer { ptr in
            for i in 0..<imageIn.texture.arrayLength {
                let region = MTLRegion(origin: MTLOriginMake(0, 0, 0), size: MTLSizeMake(1, 1, 1))

                imageIn.texture.replace(
                    region: region, mipmapLevel: 0, slice: i,
                    withBytes: ptr.baseAddress!.advanced(by: i * 4),
                    bytesPerRow: MemoryLayout<Float32>.stride * 4, bytesPerImage: 0
                )
            }
        }
    }

    func getComputeOutput() -> [Double] { imageOut.toArray() }

    func driveSignal(_ commandBuffer: MTLCommandBuffer) {
      cnnLayer.encode(commandBuffer: commandBuffer, sourceImage: imageIn, destinationImage: imageOut)
    }
}
