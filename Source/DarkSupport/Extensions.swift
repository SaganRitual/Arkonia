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

extension Double {
    func iTruncate() -> Int {
        return Int(self)
    }

    func sciTruncate(_ length: Int) -> String {
        let t = Double(truncating: self as NSNumber)
        return String(format: "%.\(length)e", t)
    }

    func sTruncate() -> String {
        let t = Double(truncating: self as NSNumber)
        return String(format: "%.20f", t)
    }

    func sTruncate(_ length: Int) -> String {
        let t = Double(truncating: self as NSNumber)
        return String(format: "%.\(length)f", t)
    }

    func dTruncate() -> Double {
        return Double(sTruncate())!
    }
}

extension CGFloat {
    func iTruncate() -> Int {
        return Double(self).iTruncate()
    }

    func dTruncate() -> Double {
        return Double(self).dTruncate()
    }

    func sTruncate() -> String {
        return Double(self).sTruncate()
    }
}

extension CGPoint {
    func iTruncate() -> CGPoint {
        return CGPoint(x: self.x.iTruncate(), y: self.y.iTruncate())
    }
}
