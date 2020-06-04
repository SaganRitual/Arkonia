import Foundation

struct AKRandom {
    static var shared = AKRandom()

    var normalizedSamples = ContiguousArray<Float>(repeating: 0, count: 200000)

    init() {
        let dist = NormalDistribution<Float>(mean: 0, standardDeviation: 3)

        for ss in 0..<normalizedSamples.count {
            normalizedSamples[ss] = dist.next(using: &ARC4RandomNumberGenerator.global)
        }
    }

    func next() -> Float { normalizedSamples.randomElement()! }
}
