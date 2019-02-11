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

infix operator !!: NilCoalescingPrecedence
func !!<T> (_ theOptional: T?, _ onError: () -> Never) -> T {
    guard let unwrapped = theOptional else { onError() }
    return unwrapped
}

func nok<T: Any>(_ theThing: T?) -> T {
    guard let it = theThing else {
        preconditionFailure("Found nil, expecting \(type(of: theThing))")
    }

    return it
}

/**
 A proper modulo operator

 - Parameters:
     - a: the number to be modded
     - n: the number to mod it by

 Swift's is different from the
 modulo operator of every other language I know.

- - -

 With profound gratitude to
 [Martin R](https://stackoverflow.com/users/1187415/martin-r)
 for his [contributions](https://stackoverflow.com/a/41180619/1610473)
 to StackOverflow.

 */
infix operator %%
func %% (_ a: Int, _ n: Int) -> Int {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}

//extension Double {
//    func iTruncate() -> Int {
//        return Int(self)
//    }
//
//    func sciTruncate(_ length: Int) -> String {
//        let t = Double(truncating: self as NSNumber)
//        return String(format: "%.\(length)e", t)
//    }
//
//    func sTruncate() -> String {
//        let t = Double(truncating: self as NSNumber)
//        return String(format: "%.20f", t)
//    }
//
//    func sTruncate(_ length: Int) -> String {
//        let t = Double(truncating: self as NSNumber)
//        return String(format: "%.\(length)f", t)
//    }
//
//    func dTruncate() -> Double {
//        return Double(sTruncate())!
//    }
//}
//
//extension Float {
//    func sTruncate() -> String {
//        return Double(self).sTruncate()
//    }
//}
//
//extension CGFloat {
//    func iTruncate() -> Int {
//        return Double(self).iTruncate()
//    }
//
//    func dTruncate() -> Double {
//        return Double(self).dTruncate()
//    }
//
//    func sTruncate() -> String {
//        return Double(self).sTruncate()
//    }
//}
//
//extension CGPoint {
//    func iTruncate() -> CGPoint {
//        return CGPoint(x: self.x.iTruncate(), y: self.y.iTruncate())
//    }
//}

extension Array {
    // It's easier for me to think about the breeders as a stack
    mutating func pop() -> Element { return self.removeFirst() }
    mutating func push(_ e: Element) { self.insert(e, at: 0) }
    mutating func popBack() -> Element { return self.removeLast() }
    mutating func pushFront(_ e: Element) { push(e) }
}

struct SetOnce<T> {
    private var meat: T?
    private var isLocked = false

    init() {}

    // Note: we don't set isLocked; we'll return the default
    // value forever until someone explicitly calls set().
    // After that we're no longer settable.
    init(defaultValue: T) { meat = defaultValue }

    public func get() -> T {
        precondition(meat != nil, "Not set")
        return meat!
    }

    // Note: we don't check isLocked. If there's a default
    // value, we want to report that we're meaty.
    public func has() -> Bool { return meat != nil }

    public mutating func set(_ newValue: T) {
        precondition(!isLocked, "Can be set only once")
        isLocked = true
        meat = newValue
    }
}
