import Foundation

// https://en.wikipedia.org/wiki/Xorshift
// Xorshift generators are among the fastest non-cryptographically-secure
// random number generators.
// Apple's rngs are way too slow for my purposes, and I don't need
// anything subtle
extension Arkonia {
    static var rng = rngXorShift64()

    struct rngXorShift64: RandomNumberGenerator {
        var boo: Double = 0
        var state: UInt64 = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)

        mutating func next() -> UInt64 {
            let a = state << 13
            state ^= a

            let b = state >> 7  // Note: shift right, not shift left!
            state ^= b

            let c = state << 17
            state ^= c

            return state
        }
    }

    static func randomBool() -> Bool { Bool.random(using: &rng) }

    static func random(in range: Range<Int>) -> Int { Int.random(in: range, using: &rng) }
    static func random(in range: ClosedRange<Int>) -> Int { Int.random(in: range, using: &rng) }

    static func random(in range: Range<Float>) -> Float { Float.random(in: range, using: &rng) }
    static func random(in range: ClosedRange<Float>) -> Float { Float.random(in: range, using: &rng) }

    static func random(in range: Range<Double>) -> Double { Double.random(in: range, using: &rng) }
    static func random(in range: ClosedRange<Double>) -> Double { Double.random(in: range, using: &rng) }

    static func random(in range: Range<CGFloat>) -> CGFloat { CGFloat.random(in: range, using: &rng) }
    static func random(in range: ClosedRange<CGFloat>) -> CGFloat { CGFloat.random(in: range, using: &rng) }

    static func randomElement<T: Collection>(in collection: T) -> T.Element {
        collection.randomElement(using: &rng)!
    }
}
