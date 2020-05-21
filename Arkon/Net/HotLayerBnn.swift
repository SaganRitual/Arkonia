import Accelerate

class HotLayerBnn {
    let biases: [BnnNumber]
    let weights: [BnnNumber]

    let biasesLayerData: BNNSLayerData
    let weightsLayerData: BNNSLayerData

    var layerParameters: BNNSFullyConnectedLayerParameters
    let hotLayer: BNNSFilter

    var neuronsOut: [BnnNumber]
    var pNeuronsIn: UnsafePointer<BnnNumber>
    var pNeuronsOut: UnsafePointer<BnnNumber>

    init(
        _ biases: ArraySlice<Double>,
        _ pNeuronsIn: UnsafePointer<BnnNumber>,
        _ cNeuronsIn: Int,
        _ cNeuronsOut: Int,
        _ weights: ArraySlice<Double>
    ) {
        self.pNeuronsIn = pNeuronsIn
        self.neuronsOut = [BnnNumber](repeating: 0, count: cNeuronsOut)
        self.pNeuronsOut = UnsafePointer(self.neuronsOut)

        self.biases = biases.prefix(cNeuronsOut).map { BnnNumber($0) }
        self.weights = weights.prefix(cNeuronsIn * cNeuronsOut).map { BnnNumber($0) }

        self.biasesLayerData = BNNSLayerData(data: self.biases, data_type: .float)
        self.weightsLayerData = BNNSLayerData(data: self.weights, data_type: .float)

        self.layerParameters = BNNSFullyConnectedLayerParameters(
            in_size: cNeuronsIn, out_size: cNeuronsOut,
            weights: self.weightsLayerData, bias: self.biasesLayerData,
            activation: BNNSActivation(function: .sigmoid)
        )

        var inputDesc = BNNSVectorDescriptor(
            size: cNeuronsIn, data_type: .float, data_scale: 0, data_bias: 0)

        var hiddenDesc = BNNSVectorDescriptor(
            size: cNeuronsOut, data_type: .float, data_scale: 0, data_bias: 0)

        let hl = (BNNSFilterCreateFullyConnectedLayer(
            &inputDesc, &hiddenDesc, &layerParameters, nil
        ))!

        hotLayer = hl
    }

    func driveSignal(_ liveInput: [BnnNumber]) {
        let result = BNNSFilterApply(hotLayer, liveInput, &self.neuronsOut)
        if result != 0 { fatalError() }
    }

    func driveSignal() {
        let result = BNNSFilterApply(hotLayer, self.pNeuronsIn, &self.neuronsOut)
        if result != 0 { fatalError() }
    }

    func getOutputBuffer() -> UnsafePointer<BnnNumber> { pNeuronsOut }
}
