import CoreGraphics

struct AKPoint: Overload2D, Hashable, HasXY, CustomDebugStringConvertible {
    // swiftlint:disable unused_setter_value
    var aa: CGFloat { get { CGFloat(x) } set { } }
    var bb: CGFloat { get { CGFloat(y) } set { } }
    // swiftlint:enable unused_setter_value

    func asPoint() -> CGPoint { return CGPoint(x: x, y: y) }

    func asSize() -> CGSize { return CGSize(width: x, height: y) }

    func asVector() -> CGVector { return CGVector(dx: x, dy: y) }

    static func makeTuple(_ xx: CGFloat, _ yy: CGFloat) -> AKPoint { AKPoint(xx, yy) }

    private func debugDescription_() -> String {
        return String(format: "%+03d%+03d", x, y)
    }

    var debugDescription: String { debugDescription_() }

    let x: Int; let y: Int

    init(_ point: AKPoint) { x = point.x; y = point.y }
    init(x: Int, y: Int) { self.x = x; self.y = y }
    init(_ xx: CGFloat, _ yy: CGFloat) { self.x = Int(xx); self.y = Int(yy) }

    static let zero = AKPoint(x: 0, y: 0)

    static func random(_ xRange: Range<Int>, _ yRange: Range<Int>) -> AKPoint {
        let xx = Int.random(in: xRange), yy = Int.random(in: yRange)
        return AKPoint(x: xx, y: yy)
    }

    static func + (_ lhs: AKPoint, _ rhs: AKPoint) -> AKPoint {
        return AKPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func - (_ lhs: AKPoint, _ rhs: AKPoint) -> AKPoint {
        return AKPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func * (_ lhs: AKPoint, _ rhs: Int) -> AKPoint {
        return AKPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}
