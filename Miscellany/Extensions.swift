import CoreGraphics

extension CGFloat { static let tau = 2 * CGFloat.pi }

func constrain<T: Numeric & Comparable>(_ a: T, lo: T, hi: T) -> T {
    let capped = min(a, hi)
    return max(capped, lo)
}

extension Array {
    mutating func popFirst() -> Element? {
        if self.isEmpty { return nil }
        return self.removeFirst()
    }
}
