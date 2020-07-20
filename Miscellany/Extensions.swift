import Foundation

extension CGFloat { static let tau = 2 * pi }
extension TimeInterval { static let tau = 2 * pi }

func constrain<T: Numeric & Comparable>(_ a: T, lo: T, hi: T) -> T {
    let capped = min(a, hi)
    return max(capped, lo)
}
