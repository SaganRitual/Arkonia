import MetalPerformanceShaders

struct GPUArray {
    static var shared = GPUArray()

    private let gpu: [MTLDevice]
    private var whichOne = 0

    init() { gpu = MTLCopyAllDevices() }

    mutating func next() -> MTLDevice {
        defer { whichOne = (whichOne + 1) % gpu.count }
        return gpu[0]
    }
}
