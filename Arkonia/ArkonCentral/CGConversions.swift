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
}

extension CGSize: SizelikeProtocol {
    init(_ width: Double, _ height: Double) {
        self = CGSize.make(width, height)
    }

    init(_ size: CGSize) {
        self = CGSize.make(size.width, size.height)
    }

    static public func make(_ width: CGFloat, _ height: CGFloat) -> CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }

    static public func make(_ width: Double, _ height: Double) -> CGSize {
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }

    static func += (_ size: CGSize, _ addend: (Double, Double)) -> CGSize {
        var newSize = size
        newSize.width += CGFloat(addend.0)
        newSize.height += CGFloat(addend.1)
        return newSize
    }

    static func / (_ size: CGSize, _ divisor: Int) -> CGSize {
        return size / Double(divisor)
    }

    static func / (_ size: CGSize, _ divisor: Double) -> CGSize {
        var newSize = size
        newSize.width /= CGFloat(divisor)
        newSize.height /= CGFloat(divisor)
        return newSize
    }

    static func * (_ size: CGSize, _ multiplier: Double) -> CGSize {
        var newSize = size
        newSize.width *= CGFloat(multiplier)
        newSize.height *= CGFloat(multiplier)
        return newSize
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

    static func += (_ point: CGPoint, _ addend: (Double, Double)) -> CGPoint {
        var newPoint = point
        newPoint.x += CGFloat(addend.0)
        newPoint.y += CGFloat(addend.1)
        return newPoint
    }

    static func *= (_ point: inout CGPoint, _ multiplier: (Double, Double)) {
        point.x *= CGFloat(multiplier.0)
        point.y *= CGFloat(multiplier.1)
    }

    static func * (_ point: CGPoint, _ multiplier: (Double, Double)) -> CGPoint {
        var newPoint = point
        newPoint.x *= CGFloat(multiplier.0)
        newPoint.y *= CGFloat(multiplier.1)
        return newPoint
    }
}
