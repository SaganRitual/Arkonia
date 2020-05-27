import Accelerate

class HotLayerBnn {
    let hotLayer: BNNSFilter
    var layerParameters: BNNSFullyConnectedLayerParameters
    let neuronsIn: UnsafeRawPointer
    let neuronsOut: UnsafeMutableRawPointer

    init(
        _ cNeuronsIn: Int,
        _ neuronsIn_: UnsafePointer<Float>,
        _ biases_: UnsafePointer<Float>,
        _ weights_: UnsafePointer<Float>,
        _ cNeuronsOut: Int,
        _ neuronsOut_: UnsafeMutablePointer<Float>
    ) {
        self.neuronsIn = UnsafeRawPointer(neuronsIn_)
        self.neuronsOut = UnsafeMutableRawPointer(neuronsOut_)

        let bb = UnsafeRawPointer(biases_)
        let biases = BNNSLayerData(data: bb, data_type: .float)

        let ww = UnsafeRawPointer(weights_)
        let weights = BNNSLayerData(data: ww, data_type: .float)

        self.layerParameters = BNNSFullyConnectedLayerParameters(
            in_size: cNeuronsIn, out_size: cNeuronsOut,
            weights: weights, bias: biases,
            activation: BNNSActivation(function: .sigmoid)
        )

        var upperLayerDescriptor = BNNSVectorDescriptor(
            size: cNeuronsIn, data_type: .float, data_scale: 0, data_bias: 0)

        var lowerLayerDescriptor = BNNSVectorDescriptor(
            size: cNeuronsOut, data_type: .float, data_scale: 0, data_bias: 0)

        guard let hl = BNNSFilterCreateFullyConnectedLayer(
            &upperLayerDescriptor, &lowerLayerDescriptor, &layerParameters, nil
        ) else { fatalError("Couldn't get BNNSFilterCreateFullyConnectedLayer() in HotLayerBnn()") }

        hotLayer = hl
    }

    deinit { hotLayer.deallocate() }

    func driveSignal() {
        let result = BNNSFilterApply(hotLayer, neuronsIn, neuronsOut)
        if result != 0 { fatalError() }
    }
}
