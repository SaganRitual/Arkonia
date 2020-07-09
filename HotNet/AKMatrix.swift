import Foundation
import MetalPerformanceShaders

struct AKMatrix {
    let alignedRawData: UnsafeMutableRawPointer
    let alignment = 0x1000
    let boundData: UnsafeMutablePointer<Number>

    private(set) var matrix: MPSMatrix?

    init(cElements: Int) {
        let cBytes_ = cElements * NumberSize
        let cBytes = AKMatrix.align(originalValue: cBytes_, to: alignment)

        alignedRawData = .allocate(byteCount: cBytes, alignment: alignment)

        boundData = alignedRawData.bindMemory(to: Number.self, capacity: cBytes)
        boundData.initialize(repeating: 0, count: cElements)
    }

    mutating func postInit(
        device: MTLDevice, cRows: Int, cColumns: Int
    ) -> UnsafePointer<Number> {
        let cBytes = cRows * cColumns * NumberSize

        let db = device.makeBuffer(
            bytesNoCopy: boundData, length: cBytes, options: .storageModeShared
        )

        let md = MPSMatrixDescriptor(
            dimensions: cRows, columns: cColumns,
            rowBytes: cColumns * NumberSize, dataType: NumberTypeInGPU
        )

        self.matrix = MPSMatrix(buffer: db!, descriptor: md)

        return UnsafePointer(boundData)
    }
}

private extension AKMatrix {
    static func align(originalValue: Int, to alignment: Int) -> Int {
        let chop = ~(alignment - 1)
        let alreadyAligned = originalValue & chop == 0
        let roundedUp = (originalValue + alignment) & chop

        return alreadyAligned ? originalValue : roundedUp
    }
}
