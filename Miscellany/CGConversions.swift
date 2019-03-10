//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

import Foundation

protocol PointlikeProtocol {
    var x: CGFloat { get set }
    var y: CGFloat { get set }

    init(x: CGFloat, y: CGFloat)
    init(_ x: Double, _ y: Double)
}

protocol SizelikeProtocol {
    var width: CGFloat { get set }
    var height: CGFloat { get set }

    init(width: CGFloat, height: CGFloat)
    init(_ width: Double, _ height: Double)
}

extension CGRect {
    static func * (_ rect: CGRect, _ multiplier: Double) -> CGRect {
        return CGRect(origin: rect.origin, size: rect.size * multiplier)
    }

    static func / (_ rect: CGRect, _ divisor: Double) -> CGRect {
        return CGRect(origin: rect.origin, size: rect.size / divisor)
    }

}

extension CGSize: SizelikeProtocol {
    init(_ width: Double, _ height: Double) {
        self = CGSize.make(width, height)
    }

    init(_ size: CGSize) {
        self = CGSize.make(size.width, size.height)
    }

    static public func make(_ size: CGSize) -> CGSize {
        return CGSize(size)
    }

    static public func make(_ width: CGFloat, _ height: CGFloat) -> CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }

    static public func make(_ width: Double, _ height: Double) -> CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }

    static func + (_ size: CGSize, _ addend: CGSize) -> CGSize {
        var newSize = size
        newSize.width += CGFloat(addend.width)
        newSize.height += CGFloat(addend.height)
        return newSize
    }

    static func - (_ size: CGSize, _ addend: CGSize) -> CGSize {
        var newSize = size
        newSize.width -= CGFloat(addend.width)
        newSize.height -= CGFloat(addend.height)
        return newSize
    }

    static func / (_ size: CGSize, _ divisor: CGFloat) -> CGSize {
        var newSize = size
        newSize.width /= divisor
        newSize.height /= divisor
        return newSize
    }

    static func / (_ size: CGSize, _ divisor: Int) -> CGSize {
        return size / Double(divisor)
    }

    static func / (_ size: CGSize, _ divisor: Double) -> CGSize {
        return size / CGFloat(divisor)
    }

    static func / (_ size: CGSize, _ divisor: CGPoint) -> CGSize {
        return CGSize(width: size.width / divisor.x, height: size.height / divisor.y)
    }

    static func *= (_ size: inout CGSize, _ multiplier: Double) {
        size.width *= CGFloat(multiplier)
        size.height *= CGFloat(multiplier)
    }

    static func * (_ size: CGSize, _ multiplier: Double) -> CGSize {
        var newSize = size
        newSize.width *= CGFloat(multiplier)
        newSize.height *= CGFloat(multiplier)
        return newSize
    }

    static prefix func - (_ size: CGSize) -> CGSize {
        return size * -1
    }
}

extension CGVector: PointlikeProtocol {
    init(x: CGFloat, y: CGFloat) { self.init(dx: x, dy: y) }
    init(_ x: Double, _ y: Double) { self.init(dx: CGFloat(x), dy: CGFloat(y)) }

    var x: CGFloat {
        get { return dx }
        set { dx = newValue }
    }

    var y: CGFloat {
        get { return dy }
        set { dy = newValue }
    }

    static func * (_ lhs: CGVector, _ rhs: CGFloat) -> CGVector {
        return CGVector(dx: lhs.dx * rhs, dy: lhs.dy * rhs)
    }

    static func / (_ lhs: CGVector, _ rhs: CGFloat) -> CGVector {
        return CGVector(dx: lhs.dx / rhs, dy: lhs.dy / rhs)
    }
}

extension CGPoint: PointlikeProtocol {
    init(_ x: Double, _ y: Double) {
        self = CGPoint.make(x, y)
    }

    init(_ size: CGSize) {
        self = CGPoint.make(size.width, size.height)
    }

    static public func make(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }

    static public func make(_ x: Double, _ y: Double) -> CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }

    static func random(x: Range<CGFloat>, y: Range<CGFloat>) -> CGPoint {
        return CGPoint(x: CGFloat.random(in: x), y: CGFloat.random(in: y))
    }

    static public func make(_ size: CGSize) -> CGPoint {
        return CGPoint(x: size.width, y: size.height)
    }

    static func += (_ point: inout CGPoint, _ addend: CGPoint) {
        point.x += addend.x
        point.y += addend.y
    }

    static func + (_ point: CGPoint, _ addend: CGPoint) -> CGPoint {
        var newPoint = point
        newPoint.x += CGFloat(addend.x)
        newPoint.y += CGFloat(addend.y)
        return newPoint
    }

    static func - (_ point: CGPoint, _ subtrahendOrWhatever: SizelikeProtocol) -> CGPoint {
        let x = point.x - subtrahendOrWhatever.width
        let y = point.y - subtrahendOrWhatever.height
        return CGPoint(x: x, y: y)
    }

    static func - (_ point: CGPoint, _ subtrahendOrWhatever: CGFloat) -> CGPoint {
        var newPoint = point
        newPoint.x -= subtrahendOrWhatever
        newPoint.y -= subtrahendOrWhatever
        return newPoint
    }

    static func / (_ point: CGPoint, _ divisor: CGFloat) -> CGPoint {
        var newPoint = point
        newPoint.x /= divisor
        newPoint.y /= divisor
        return newPoint
    }

    static func / (_ point: CGPoint, _ divisor: Double) -> CGPoint {
        return point / CGFloat(divisor)
    }

    static func /= (_ point: inout CGPoint, _ divisor: Double) {
        point.x /= CGFloat(divisor)
        point.y /= CGFloat(divisor)
    }

    static func *= (_ point: inout CGPoint, _ multiplier: (Double, Double)) {
        point.x *= CGFloat(multiplier.0)
        point.y *= CGFloat(multiplier.1)
    }

    static func *= (_ point: inout CGPoint, _ multiplier: Double) {
        point.x *= CGFloat(multiplier)
        point.y *= CGFloat(multiplier)
    }

    static func * (_ point: CGPoint, _ multiplier: Double) -> CGPoint {
        return point * CGFloat(multiplier)
    }

    static func * (_ point: CGPoint, _ multiplier: CGFloat) -> CGPoint {
        var newPoint = point
        newPoint.x *= multiplier
        newPoint.y *= multiplier
        return newPoint
    }

    static func * (_ point: CGPoint, _ multiplier: CGPoint) -> CGPoint {
        var newPoint = point
        newPoint.x *= multiplier.x
        newPoint.y *= multiplier.y
        return newPoint
    }

   func distance(to theOtherPoint: CGPoint) -> CGFloat {
       let dx = theOtherPoint.x - self.x
       let dy = theOtherPoint.y - self.y
       return sqrt((dx * dx) + (dy * dy))
   }
}