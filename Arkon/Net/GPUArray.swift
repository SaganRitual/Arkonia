import MetalPerformanceShaders

struct GPUArray {
    static var shared = GPUArray()

    private let gpu: [MTLDevice]
    private var whichOne = 0

    init() { gpu = MTLCopyAllDevices() }

    mutating func next() -> MTLDevice {
//        defer { whichOne = (whichOne + 1) % gpu.count }

        // The radeon always returns zeros; I read something about
        // how one gpu is supposed to be for graphics only, but I don't recall
        // exactly what it said, and I can't remember now where I read it
        print(gpu[whichOne].description)
        return gpu[whichOne]
    }
}
