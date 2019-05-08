import CoreGraphics

/// Arithmetic extensions for CGPoint, CGSize, and CGVector.
/// All of the operators +, -, *, /, and unary minus are supported. Where
/// applicable, operators can be applied to point/size/vector + point/size/vector,
/// as well as point/size/vector + CGFloat and CGFloat + point/size/vector.
protocol Overload2D {
    /// Really for internal use, but publicly available so the unit tests can use them.
    var aa: CGFloat { get set }
    var bb: CGFloat { get set }

    /// So we can create any one of our types without needing argument names
    /// - Parameters:
    ///   - xx: depending on the object being created, this is the x-coordinate,
    ///        or the width, or the dx component
    ///   - yy: depending on the object being created, this is the y-coordinate,
    ///        or the height, or the dy component
    init(_ xx: CGFloat, _ yy: CGFloat)

    /// Convenience function for easy conversion to CGPoint from the others,
    /// to make arithmetic operations between the types easier to write and read.
    func asPoint() -> CGPoint
    /// Convenience function for easy conversion to CGSize from the others,
    /// to make arithmetic operations between the types easier to write and read.
    func asSize() -> CGSize
    /// Convenience function for easy conversion to CGVector from the others,
    /// to make arithmetic operations between the types easier to write and read.
    func asVector() -> CGVector

    /// So we can create any one of our types without needing argument names
    ///
    /// Same functionality as init(_:,_:)
    ///
    /// - Parameters:
    ///   - xx: depending on the object being created, this is the x-coordinate,
    ///        or the width, or the dx component
    ///   - yy: depending on the object being created, this is the y-coordinate,
    ///        or the height, or the dy component
    static func makeTuple(_ xx: CGFloat, _ yy: CGFloat) -> Self

    /// Sometimes the problem can be understood better using polar coordinates
    ///
    /// - Parameters:
    ///   - radius: the radius of the circle on which the x/y coordinate lies
    ///   - theta: the angle from y = 0 to the x/y coordinate, in radians
    static func polar(radius: CGFloat, theta: CGFloat) -> Self

    /// Unary minus: negates both scalars in the tuple
    static prefix func - (_ myself: Self) -> Self

    /// Basic arithmetic with tuples on both sides of the operator.
    /// These return a new tuple with lhsTuple.0 (op) rhsTuple.0, lhsTuple.1 (op) rhsTuple.1.
    ///
    /// Examples:
    ///
    /// CGPoint(x: 10, y: 3) + CGPoint(17, 37) = CGPoint(x: 10 + 17, y: 3 + 37)
    ///
    /// CGSize(w: 5, h: 7) * CGSize(w: 12, h: 13) = CGSize(w: 5 * 12, h: 7 * 13)
    static func + (_ lhs: Self, _ rhs: Self) -> Self
    static func - (_ lhs: Self, _ rhs: Self) -> Self
    static func * (_ lhs: Self, _ rhs: Self) -> Self
    static func / (_ lhs: Self, _ rhs: Self) -> Self

    /// Basic arithmetic with tuple (op) CGFloat, or CGFloat (op) tuple
    /// These return a new tuple with lhsTuple.0 (op) rhs, lhsTuple.1 (op) rhs.
    ///
    /// Examples:
    ///
    /// CGPoint(x: 10, y: 3) / 42 = CGPoint(x: 10 / 42, y: 3 / 42)
    ///
    /// CGSize(width: 5, height: 7) - 137 = CGSize(width: 5 - 137, height: 7 - 137)
    static func + (_ lhs: Self, _ rhs: CGFloat) -> Self
    static func - (_ lhs: Self, _ rhs: CGFloat) -> Self
    static func * (_ lhs: Self, _ rhs: CGFloat) -> Self
    static func / (_ lhs: Self, _ rhs: CGFloat) -> Self

    static func + (_ lhs: CGFloat, _ rhs: Self) -> Self
    static func - (_ lhs: CGFloat, _ rhs: Self) -> Self
    static func * (_ lhs: CGFloat, _ rhs: Self) -> Self
    static func / (_ lhs: CGFloat, _ rhs: Self) -> Self

    /// Compound assignment operators. These all work the same as the basic operators,
    /// applying compound assignment the same as the usual arithmetic versions.
    static func += (_ lhs: inout Self, _ rhs: Self)
    static func -= (_ lhs: inout Self, _ rhs: Self)
    static func *= (_ lhs: inout Self, _ rhs: Self)
    static func /= (_ lhs: inout Self, _ rhs: Self)

    static func += (_ lhs: inout Self, _ rhs: CGFloat)
    static func -= (_ lhs: inout Self, _ rhs: CGFloat)
    static func *= (_ lhs: inout Self, _ rhs: CGFloat)
    static func /= (_ lhs: inout Self, _ rhs: CGFloat)
}

// MARK: The lonely hypotenuse

extension Overload2D {
    var hypotenuse: CGFloat { return sqrt(aa * aa + bb * bb) }
}

// MARK: Polar coordinates

extension Overload2D {
    var radius: CGFloat { return hypotenuse }
    var theta: CGFloat { return atan2(bb, aa) }

    static func polar(radius: CGFloat, theta: CGFloat) -> Self {
        return Self(radius * cos(theta), radius * sin(theta))
    }
}

// MARK: Operators

extension Overload2D {
    static prefix func - (_ myself: Self) -> Self {
        return myself * -1.0
    }

    static func + (_ lhs: Self, _ rhs: Self) -> Self {
        return makeTuple(lhs.aa + rhs.aa, lhs.bb + rhs.bb)
    }
    static func - (_ lhs: Self, _ rhs: Self) -> Self {
        return makeTuple(lhs.aa - rhs.aa, lhs.bb - rhs.bb)
    }
    static func * (_ lhs: Self, _ rhs: Self) -> Self {
        return makeTuple(lhs.aa * rhs.aa, lhs.bb * rhs.bb)
    }
    static func / (_ lhs: Self, _ rhs: Self) -> Self {
        return makeTuple(lhs.aa / rhs.aa, lhs.bb / rhs.bb)
    }

    static func + (_ lhs: Self, _ rhs: CGFloat) -> Self {
        return makeTuple(lhs.aa + rhs, lhs.bb + rhs)
    }
    static func - (_ lhs: Self, _ rhs: CGFloat) -> Self {
        return makeTuple(lhs.aa - rhs, lhs.bb - rhs)
    }
    static func * (_ lhs: Self, _ rhs: CGFloat) -> Self {
        return makeTuple(lhs.aa * rhs, lhs.bb * rhs)
    }
    static func / (_ lhs: Self, _ rhs: CGFloat) -> Self {
        return makeTuple(lhs.aa / rhs, lhs.bb / rhs)
    }

    static func + (_ lhs: CGFloat, _ rhs: Self) -> Self {
        return makeTuple(lhs + rhs.aa, lhs + rhs.bb)
    }
    static func - (_ lhs: CGFloat, _ rhs: Self) -> Self {
        return makeTuple(lhs - rhs.aa, lhs - rhs.bb)
    }
    static func * (_ lhs: CGFloat, _ rhs: Self) -> Self {
        return makeTuple(lhs * rhs.aa, lhs * rhs.bb)
    }
    static func / (_ lhs: CGFloat, _ rhs: Self) -> Self {
        return makeTuple(lhs / rhs.aa, lhs / rhs.bb)
    }

    static func += (_ lhs: inout Self, _ rhs: Self) {
        lhs.aa += rhs.aa; lhs.bb += rhs.bb
    }
    static func -= (_ lhs: inout Self, _ rhs: Self) {
        lhs.aa -= rhs.aa; lhs.bb -= rhs.bb
    }
    static func *= (_ lhs: inout Self, _ rhs: Self) {
        lhs.aa *= rhs.aa; lhs.bb *= rhs.bb
    }
    static func /= (_ lhs: inout Self, _ rhs: Self) {
        lhs.aa /= rhs.aa; lhs.bb /= rhs.bb
    }

    static func += (_ lhs: inout Self, _ rhs: CGFloat) {
        lhs.aa += rhs; lhs.bb += rhs
    }
    static func -= (_ lhs: inout Self, _ rhs: CGFloat) {
        lhs.aa -= rhs; lhs.bb -= rhs
    }
    static func *= (_ lhs: inout Self, _ rhs: CGFloat) {
        lhs.aa *= rhs; lhs.bb *= rhs
    }
    static func /= (_ lhs: inout Self, _ rhs: CGFloat) {
        lhs.aa /= rhs; lhs.bb /= rhs
    }
}

extension CGPoint: Overload2D {
    var aa: CGFloat { get { return self.x } set { self.x = newValue } }
    var bb: CGFloat { get { return self.y } set { self.y = newValue } }

    init(_ xx: CGFloat, _ yy: CGFloat) {
        self.init(x: xx, y: yy)
    }

    init(radius: CGFloat, theta: CGFloat) {
        self.init(x: radius * cos(theta), y: radius * sin(theta))
    }

    static func makeTuple(_ xx: CGFloat, _ yy: CGFloat) -> CGPoint {
        return CGPoint(x: xx, y: yy)
    }

    static func makeTuple(_ xx: CGFloat, _ yy: CGFloat) -> CGSize {
        return CGSize.makeTuple(xx, yy)
    }

    static func makeTuple(_ xx: CGFloat, _ yy: CGFloat) -> CGVector {
        return CGVector.makeTuple(xx, yy)
    }

    static func makeVector(from a: CGPoint, to b: CGPoint) -> CGVector {
        return (b - a).asVector()
    }

    static func random(in range: Range<CGFloat>) -> CGPoint {
        return CGPoint(x: CGFloat.random(in: range), y: CGFloat.random(in: range))
    }

    static func random(xRange: Range<CGFloat>, yRange: Range<CGFloat>) -> CGPoint {
        return CGPoint(x: CGFloat.random(in: xRange), y: CGFloat.random(in: yRange))
    }

    func asPoint() -> CGPoint {
        return CGPoint(x: x, y: y)
    }

    func asSize() -> CGSize {
        return CGSize(width: x, height: y)
    }

    func asVector() -> CGVector {
        return CGVector(dx: x, dy: y)
    }

    func distance(to otherPoint: CGPoint) -> CGFloat {
        return (otherPoint - self).hypotenuse
    }

    func makeVector(to otherPoint: CGPoint) -> CGVector {
        return CGPoint.makeVector(from: self, to: otherPoint)
    }
}

extension CGSize: Overload2D {
    var aa: CGFloat { get { return self.width } set { self.width = newValue } }
    var bb: CGFloat { get { return self.height } set { self.height = newValue } }

    init(_ width: CGFloat, _ height: CGFloat) {
        self.init(width: width, height: height)
    }

    init(radius: CGFloat, theta: CGFloat) {
        self.init(width: radius * cos(theta), height: radius * sin(theta))
    }

    static func makeTuple(_ width: CGFloat, _ height: CGFloat) -> CGPoint {
        return CGPoint.makeTuple(width, height)
    }

    static func makeTuple(_ width: CGFloat, _ height: CGFloat) -> CGSize {
        return CGSize(width: width, height: height)
    }

    static func makeTuple(_ width: CGFloat, _ height: CGFloat) -> CGVector {
        return CGVector.makeTuple(width, height)
    }

    static func random(in range: Range<CGFloat>) -> CGSize {
        return CGSize(width: CGFloat.random(in: range), height: CGFloat.random(in: range))
    }

    static func random(widthRange: Range<CGFloat>, heightRange: Range<CGFloat>) -> CGSize {
        return CGSize(width: CGFloat.random(in: widthRange), height: CGFloat.random(in: heightRange))
    }

    func asPoint() -> CGPoint {
        return CGPoint(x: width, y: height)
    }

    func asSize() -> CGSize {
        return CGSize(width: width, height: height)
    }

    func asVector() -> CGVector {
        return CGVector(dx: width, dy: height)
    }
}

extension CGVector: Overload2D {
    var aa: CGFloat { get { return self.dx } set { self.dx = newValue } }
    var bb: CGFloat { get { return self.dy } set { self.dy = newValue } }

    var magnitude: CGFloat { return hypotenuse }

    static let infinity = CGVector(dx: CGFloat.infinity, dy: CGFloat.infinity)

    init(_ dx: CGFloat, _ dy: CGFloat) {
        self.init(dx: dx, dy: dy)
    }

    init(radius: CGFloat, theta: CGFloat) {
        self.init(dx: radius * cos(theta), dy: radius * sin(theta))
    }

    static func makeTuple(_ dx: CGFloat, _ dy: CGFloat) -> CGPoint {
        return CGPoint.makeTuple(dx, dy)
    }

    static func makeTuple(_ dx: CGFloat, _ dy: CGFloat) -> CGSize {
        return CGSize.makeTuple(dx, dy)
    }

    static func makeTuple(_ dx: CGFloat, _ dy: CGFloat) -> CGVector {
        return CGVector(dx: dx, dy: dy)
    }

    static func random(in range: Range<CGFloat>) -> CGVector {
        return CGVector(dx: CGFloat.random(in: range), dy: CGFloat.random(in: range))
    }

    static func random(dxRange: Range<CGFloat>, dyRange: Range<CGFloat>) -> CGVector {
        return CGVector(dx: CGFloat.random(in: dxRange), dy: CGFloat.random(in: dyRange))
    }

    func asPoint() -> CGPoint {
        return CGPoint(x: dx, y: dy)
    }

    func asSize() -> CGSize {
        return CGSize(width: dx, height: dy)
    }

    func asVector() -> CGVector {
        return CGVector(dx: dx, dy: dy)
    }

    func normalized() -> CGVector {
        return CGVector(dx: self.dx / hypotenuse, dy: self.dy / hypotenuse)
    }
}
