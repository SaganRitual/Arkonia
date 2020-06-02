import Accelerate

class HotLayerBnn {
    let hotLayer: BNNSFilter
    var layerParameters: BNNSFullyConnectedLayerParameters
    let pNeuronsIn: UnsafeRawPointer
    let pNeuronsOut: UnsafeMutableRawPointer

    init(
        _ cNeuronsIn: Int,
        _ pNeuronsIn: UnsafePointer<Float>,
        _ pBiases: UnsafePointer<Float>,
        _ pWeights: UnsafePointer<Float>,
        _ cNeuronsOut: Int,
        _ pNeuronsOut: UnsafeMutablePointer<Float>
    ) {
        self.pNeuronsOut = UnsafeMutableRawPointer(pNeuronsOut)
        self.pNeuronsIn = UnsafeRawPointer(pNeuronsIn)

        let rb = UnsafeRawPointer(pBiases)
        let rawBiases = BNNSLayerData(data: rb, data_type: .float)

        let rw = UnsafeRawPointer(pWeights)
        let rawWeights = BNNSLayerData(data: rw, data_type: .float)

        self.layerParameters = BNNSFullyConnectedLayerParameters(
            in_size: cNeuronsIn, out_size: cNeuronsOut,
            weights: rawWeights, bias: rawBiases,
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

    func driveSignal() {
        let result = BNNSFilterApply(hotLayer, pNeuronsIn, pNeuronsOut)
        if result != 0 { fatalError() }
    }

    func release() { hotLayer.deallocate(); BNNSFilterDestroy(hotLayer) }
}
