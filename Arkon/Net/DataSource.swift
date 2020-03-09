import MetalPerformanceShaders

// The weights (and bias terms) must be provided by a data source object.
// This also returns an MPSCNNConvolutionDescriptor that has the kernel size,
// number of channels, which activation function to use, etc.
class DataSource: NSObject, MPSCNNConvolutionDataSource {
    let biasesArray: [Float]
    var biasesForDevice: UnsafeMutablePointer<Float>
    let inputFeatureChannels: Int
    let kernelWidth: Int
    let kernelHeight: Int
    let name: String
    let outputFeatureChannels: Int
    let weightsArray: [Float]
    var weightsForDevice: UnsafeMutableRawPointer

    init(
        _ biases: ArraySlice<Double>,
        _ device: MTLDevice,
        _ name: String,
        _ kernelWidth: Int,
        _ kernelHeight: Int,
        _ inputFeatureChannels: Int,
        _ outputFeatureChannels: Int,
        _ weights: ArraySlice<Double>
    ) {
        self.biasesArray = biases.map { Float($0) }
        self.biasesForDevice = UnsafeMutablePointer(mutating: self.biasesArray)

        self.weightsArray = weights.map { Float($0) }

        var weightsByteBuffer: Data?
        self.weightsArray.withUnsafeBufferPointer { weightsByteBuffer = Data(buffer: $0) }

        self.weightsForDevice = UnsafeMutableRawPointer(mutating: (weightsByteBuffer! as NSData).bytes)

        self.inputFeatureChannels = inputFeatureChannels
        self.kernelWidth = kernelWidth
        self.kernelHeight = kernelHeight
        self.name = name
        self.outputFeatureChannels = outputFeatureChannels
    }

    func biasTerms() -> UnsafeMutablePointer<Float>? { biasesForDevice }

    func copy(with zone: NSZone? = nil) -> Any {
        fatalError("copyWithZone not implemented")
    }

    func dataType() -> MPSDataType { .float32 }

    func descriptor() -> MPSCNNConvolutionDescriptor {
        let desc = MPSCNNConvolutionDescriptor(
            kernelWidth: kernelWidth,
            kernelHeight: kernelHeight,
            inputFeatureChannels: inputFeatureChannels,
            outputFeatureChannels: outputFeatureChannels
        )

        desc.fusedNeuronDescriptor = MPSNNNeuronDescriptor.cnnNeuronDescriptor(with: .none, a: 1, b: 1)
        return desc
    }

    func label() -> String? { name }

    func load() -> Bool { true }

    func purge() { }

    func weights() -> UnsafeMutableRawPointer { weightsForDevice }
}
