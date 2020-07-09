import MetalPerformanceShaders

typealias Number = Float

let NumberSize = MemoryLayout<Number>.size
let NumberTypeInGPU = MPSDataType.float32

final class HotNetMps: HotNet {
    let device = GPUArray.shared.next()
    var gpuLayers = [HotLayerMps]()

    init(
        _ netStructure: NetStructure,
        _ pBiases_: UnsafePointer<Number>,
        _ pWeights_: UnsafePointer<Number>
    ) {
        let dd = netStructure.layerDescriptors

        var pBiases = pBiases_
        var pWeights = pWeights_

        // Connect each upper layer to the lower layer
        gpuLayers = zip(dd.dropLast(), dd.dropFirst()).map {
            cNeuronsIn, cNeuronsOut in

            defer {
                pBiases  += cNeuronsOut
                pWeights += (cNeuronsIn * cNeuronsOut)
            }

            return HotLayerMps(device, cNeuronsIn, cNeuronsOut, pBiases, pWeights)
        }
    }

    func driveSignal(_ onComplete: @escaping () -> Void) {
        var layerSS = 0

        func driveSignal_A() { gpuLayers[layerSS].driveSignal(driveSignal_B) }

        func driveSignal_B(_: MTLCommandBuffer) {
            layerSS += 1

            if layerSS < gpuLayers.count { driveSignal_A() }
            else                         { onComplete() }
        }
    }

    func release() { }
}
