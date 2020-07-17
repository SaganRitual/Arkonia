import MetalPerformanceShaders

final class HotNetCnn: HotNet {
    let commandQueue: MTLCommandQueue
    let device = GPUArray.shared.next()
    var hotLayers = [HotLayerCnn]()

    init(_ coldLayers: [Int], _ biases: [Double], _ weights: [Double]) {
        let cq = (device.makeCommandQueue())!
        commandQueue = cq

        let CL = coldLayers
        var biasesIxL = 0, biasesIxR = 0
        var weightsIxL = 0, weightsIxR = 0

        var inputImgDesc = MPSImageDescriptor(channelFormat: .float32, width: 1, height: 1, featureChannels: CL[0])
        var inputImage = MPSImage(device: device, imageDescriptor: inputImgDesc)

        hotLayers = zip(0..<CL.count - 1, 1..<CL.count).map { upperLayerIx, lowerLayerIx in
            let cNeuronsIn = CL[upperLayerIx]
            let cNeuronsOut = CL[lowerLayerIx]

            biasesIxR += cNeuronsOut
            weightsIxR += cNeuronsIn * cNeuronsOut

            let outputImgDesc = MPSImageDescriptor(channelFormat: .float32, width: 1, height: 1, featureChannels: cNeuronsOut)
            let outputImage = MPSImage(device: device, imageDescriptor: outputImgDesc)

            let hotLayer = HotLayerCnn(
                biases[biasesIxL..<biasesIxR],
                cNeuronsIn, cNeuronsOut, device,
                inputImage, outputImage,
                weights[weightsIxL..<weightsIxR]
            )

            inputImgDesc = outputImgDesc
            inputImage = outputImage

            biasesIxL = biasesIxR
            weightsIxL = weightsIxR

            return hotLayer
        }
    }

    func driveSignal(
        _ sensoryInputs: [Double], _ onComplete: @escaping ([Double]) -> Void
    ) {
        let commandBuffer = (commandQueue.makeCommandBuffer())!

        chargeInput(sensoryInputs[...])

        hotLayers.forEach { layer in layer.driveSignal(commandBuffer) }

        commandBuffer.addCompletedHandler { _ in
//            self.hotLayers.forEach { print($0.getComputeOutput()) }
            let motorOutputs = self.hotLayers.last!.getComputeOutput()
            mainDispatch { onComplete(motorOutputs) }
        }

        commandBuffer.commit()
    }
}

extension HotNetCnn {
    func chargeInput(_ rawValues: ArraySlice<Double>) {
        hotLayers[0].chargeLayerInput(rawValues)
    }
}
