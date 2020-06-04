import CoreGraphics

func six(_ point: AKPoint?) -> String { point == nil ? "<nil>" : "\(point!)"}

struct AKPoint: Overload2D, Hashable, CustomDebugStringConvertible {
    // swiftlint:disable unused_setter_value
    var aa: CGFloat { get { CGFloat(x) } set { } }
    var bb: CGFloat { get { CGFloat(y) } set { } }
    // swiftlint:enable unused_setter_value

    func asPoint() -> CGPoint { return CGPoint(x: x, y: y) }

    func asSize() -> CGSize { return CGSize(width: x, height: y) }

    func asVector() -> CGVector { return CGVector(dx: x, dy: y) }

    static func makeTuple(_ xx: CGFloat, _ yy: CGFloat) -> AKPoint { AKPoint(xx, yy) }

    var debugDescription: String { String(format: "%+03d%+03d", x, y) }

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

struct AKSize: Overload2D, Hashable, CustomDebugStringConvertible {
    // swiftlint:disable unused_setter_value
    var aa: CGFloat { get { CGFloat(width) } set { } }
    var bb: CGFloat { get { CGFloat(height) } set { } }
    // swiftlint:enable unused_setter_value

    func area() -> Int { return width * height }

    func asPoint() -> CGPoint { return CGPoint(x: width, y: height) }

    func asSize() -> CGSize { return CGSize(width: width, height: height) }

    func asVector() -> CGVector { return CGVector(dx: width, dy: height) }

    static func makeTuple(_ ww: CGFloat, _ hh: CGFloat) -> AKSize { AKSize(ww, hh) }

    var debugDescription: String { String(format: "%+03d%+03d", width, height) }

    let width: Int; let height: Int

    init(_ size: AKSize) { width = size.width; height = size.height }
    init(width: Int, height: Int) { self.width = width; self.height = height }
    init(_ ww: CGFloat, _ hh: CGFloat) { self.width = Int(ww); self.height = Int(hh) }

    static let zero = AKSize(width: 0, height: 0)

    static func + (_ lhs: AKSize, _ rhs: AKSize) -> AKSize {
        return AKSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func - (_ lhs: AKSize, _ rhs: AKSize) -> AKSize {
        return AKSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    static func * (_ lhs: AKSize, _ rhs: Int) -> AKSize {
        return AKSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
}
