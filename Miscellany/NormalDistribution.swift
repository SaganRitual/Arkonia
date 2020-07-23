import Foundation

struct AKRandomNumberFakerator {
    static var shared: AKRandomNumberFakerator?

    static let cSamples = UInt64(10000)
    var normalizedSamples = ContiguousArray<Float>(
        repeating: 0, count: Int(AKRandomNumberFakerator.cSamples)
    )

    var uniformSamples = ContiguousArray<Float>(
        repeating: 0, count: Int(AKRandomNumberFakerator.cSamples)
    )

    init() {
        let normal = NormalDistribution<Float>(mean: 0, standardDeviation: 3)
        let uniform = UniformFloatingPointDistribution(lowerBound: -1, upperBound: 1)

        var max: Float = 0
        for ss in 0..<normalizedSamples.count {
            normalizedSamples[ss] = normal.next(using: &ARC4RandomNumberGenerator.global)
            uniformSamples[ss] = Float(uniform.next(using: &ARC4RandomNumberGenerator.global))
            if abs(normalizedSamples[ss]) > max { max = normalizedSamples[ss] }
        }

        for ss in 0..<normalizedSamples.count {
            normalizedSamples[ss] /= max
            if abs(normalizedSamples[ss]) == 1 { normalizedSamples[ss] = 0 }
        }
    }
}

struct AKRandomer: IteratorProtocol {
    typealias Element = Float

    enum Mode { case normal, uniform }

    init(_ mode: Mode = .normal) { self.mode = mode }

    let mode: Mode

    var ss: Int = Int.random(in: 0..<Int(AKRandomNumberFakerator.cSamples))

    mutating func next() -> Float? {
        if mode == .uniform { return nextUniform() }

        defer { ss = (ss + 1) % Int(AKRandomNumberFakerator.cSamples) }

        return AKRandomNumberFakerator.shared!.normalizedSamples[ss]
    }

    mutating private func nextUniform() -> Float? {
        defer { ss = (ss + 1) % Int(AKRandomNumberFakerator.cSamples) }
        return AKRandomNumberFakerator.shared!.uniformSamples[ss]
    }

    mutating func bool() -> Bool { next()! < 0 }
    mutating func positive() -> Float { abs(next()!) }

    mutating func inRange(_ range: Range<Int>) -> Int {
        let offset = abs(next()!) * Float(range.count)
        return Int(offset) + range.lowerBound
    }

    mutating func inRange(_ range: Range<Float>) -> Float {
        let offset = abs(next()!) * Float(range.upperBound - range.lowerBound)
        return Float(offset) + range.lowerBound
    }
}
