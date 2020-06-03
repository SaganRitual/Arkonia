import GameplayKit
import GameKit

enum NetMutation: CaseIterable {
    case dropLayer, duplicateLayer, duplicateAndMutateLayer, insertRandomLayer, mutateCRings
}

enum Mutator {
    static let dist = NormalDistribution<Float>(mean: 0, standardDeviation: 3)

    static let mutationValue: (() -> Float) = {
        var normalizer = Float(0)

        let rawSamples: [Float] = stride(from: -1000, to: 1000, by: 1).map({ _ in
            let n = dist.next(using: &ARC4RandomNumberGenerator.global)
            if abs(n) > abs(normalizer) { normalizer = n }
            return n
        })

        let cSamples = UInt64(rawSamples.count)
        let normalizedSamples = rawSamples.map { $0 / normalizer }

        return {
            let ns = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
            let ss = Int(ns % cSamples)
            return normalizedSamples[ss]
        }
    }()

    static func mutate(from value: Float) -> (Float, Bool) {
        // The mutation value is from a normal curve on -1.0..<1.0
        // Add 1/10 of that to the value we got, which should
        // also be in -1.0..<1.0
        let nu = Mutator.mutationValue()
        Debug.log(level: 187) { "mutate from \(value) + \(nu) to \(value + nu)"}

        // If next uniform is zero, we didn't change anything
        return (value + nu, nu != 0)
    }
}
