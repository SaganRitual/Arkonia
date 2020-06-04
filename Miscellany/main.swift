import Foundation

let mutationValue: (() -> Float) = {
        let dist = NormalDistribution<Float>(mean: 0, standardDeviation: 3)

        var normalizer = Float(0)

        let rawSamples: [Float] = stride(from: -100000, to: 100000, by: 1).map({ _ in
            let n = dist.next(using: &ARC4RandomNumberGenerator.global)
            if abs(n) > abs(normalizer) { normalizer = n }
            return n
        })

        let normalizedSamples = rawSamples.map { $0 / normalizer }

        return {
            return normalizedSamples.randomElement()!
        }
}()

let h = Debug.Histogram()

for _ in 0..<1 {
    let m = Double(mutationValue())
    h.histogrize(m, scale: 100, inputRange: .minusOneToOne)
}

Debug.waitForLogToClear()
