struct AKPoint: Hashable, HasXY, CustomDebugStringConvertible {
    var debugDescription: String { return "(\(x), \(y))" }

    let x: Int; let y: Int

    init(_ point: AKPoint) { x = point.x; y = point.y }
    init(x: Int, y: Int) { self.x = x; self.y = y }

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
