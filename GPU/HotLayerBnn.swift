import Accelerate

class HotLayerBnn {
    var layerParameters: BNNSFullyConnectedLayerParameters
    let hotLayer: BNNSFilter

    private(set) var neuronsOut: [BnnNumber]
    var pNeuronsIn: UnsafePointer<BnnNumber>

    init(
        _ biases: UnsafeRawPointer,
        _ pNeuronsIn: UnsafePointer<BnnNumber>,
        _ cNeuronsIn: Int,
        _ cNeuronsOut: Int,
        _ weights: UnsafeRawPointer
    ) {
        self.pNeuronsIn = pNeuronsIn
        self.neuronsOut = [BnnNumber](repeating: 0, count: cNeuronsOut)

        let bnnBiases = BNNSLayerData(data: biases, data_type: .float)
        let bnnWeights = BNNSLayerData(data: weights, data_type: .float)

        self.layerParameters = BNNSFullyConnectedLayerParameters(
            in_size: cNeuronsIn, out_size: cNeuronsOut,
            weights: bnnWeights, bias: bnnBiases,
            activation: BNNSActivation(function: .sigmoid)
        )

        var inputDesc = BNNSVectorDescriptor(
            size: cNeuronsIn, data_type: .float, data_scale: 0, data_bias: 0)

        var hiddenDesc = BNNSVectorDescriptor(
            size: cNeuronsOut, data_type: .float, data_scale: 0, data_bias: 0)

        guard let hl = BNNSFilterCreateFullyConnectedLayer(
            &inputDesc, &hiddenDesc, &layerParameters, nil
        ) else { fatalError("Couldn't get BNNSFilterCreateFullyConnectedLayer() in HotLayerBnn()") }

        hotLayer = hl
    }

    deinit { hotLayer.deallocate() }

    func driveSignal(_ liveInput: [BnnNumber]) {
        let result = BNNSFilterApply(hotLayer, liveInput, &self.neuronsOut)
        if result != 0 { fatalError() }
    }

    func driveSignal() {
        let result = BNNSFilterApply(hotLayer, self.pNeuronsIn, &self.neuronsOut)
        if result != 0 { fatalError() }
    }

    func getOutputBuffer() -> UnsafePointer<BnnNumber> { return UnsafePointer(neuronsOut) }
}
