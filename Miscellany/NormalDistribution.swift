import Foundation

struct AKRandomNumberFakerator {
    static var shared = AKRandomNumberFakerator()

    static let cSamples = UInt64(200000)
    var normalizedSamples = ContiguousArray<Float>(
        repeating: 0, count: Int(AKRandomNumberFakerator.cSamples)
    )

    init() {
        let dist = NormalDistribution<Float>(mean: 0, standardDeviation: 3)

        for ss in 0..<normalizedSamples.count {
            normalizedSamples[ss] = dist.next(using: &ARC4RandomNumberGenerator.global)
        }
    }
}

struct AKRandomer: IteratorProtocol {
    typealias Element = Float

    var ss: Int = Int.random(in: 0..<Int(AKRandomNumberFakerator.cSamples))

    mutating func next() -> Float? {
        defer { ss = (ss + 1) % Int(AKRandomNumberFakerator.cSamples) }
        return AKRandomNumberFakerator.shared.normalizedSamples[ss]
    }

    mutating func bool() -> Bool { next()! < 0 }
    mutating func positive() -> Float { abs(next()!) }

    mutating func inRange(_ range: Range<Int>) -> Int { Int(abs(next()!) * Float(range.upperBound)) }
    mutating func inRange(_ range: Range<Float>) -> Float { abs(next()!) * range.upperBound }
}
