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

// With deepest gratitude to Stack Overflow dude:
// https://stackoverflow.com/users/97337/rob-napier
// https://stackoverflow.com/a/38413254/1610473
//
public class LoopIterator<Base: Collection>: IteratorProtocol {

    let collection: Base
    var index: Base.Index
    var primedForCompact = false

    var count: Int { return collection.count }

    public init(_ collection: Base, _ startOffset: Int = 0) {
        self.collection = collection

        // Proper behavior for modulo--Swift does it wrong
        let s = startOffset %% collection.count
        self.index = collection.index(collection.startIndex, offsetBy: s)
    }

    public func next() -> Base.Iterator.Element? {
        preconditionFailure("The iterator protocol requires this in the base class")
    }
}

// With deepest gratitude to reddit dude
// https://www.reddit.com/user/sdker
// https://www.reddit.com/r/swift/comments/a6d1o2/trouble_with_an_iterator_over_a_collection_of/ebtwg1o
//
protocol LoopIterable {
    associatedtype Wrapped

    var loopIterableSelf: Wrapped? { get }
}

extension Optional: LoopIterable {
    public var loopIterableSelf: Wrapped? {
        switch self {
        case .some(let value): return value
        case .none: return nil
        }
    }
}

extension LoopIterator where Base.Element: LoopIterable {

    internal func compactNext() -> Base.Element.Wrapped {
        if !primedForCompact { return primeForCompact() }

        while true {
            guard let wrapper = next() else { continue }
            guard let meat = wrapper.loopIterableSelf else { preconditionFailure() }

            return meat
        }
    }

    internal func primeForCompact() -> Base.Element.Wrapped {
        primedForCompact = true

        if let wrapper = next(), let meat = wrapper.loopIterableSelf {
            return meat
        }

        return compactNext()
    }

}

public class ForwardLoopIterator<Base: Collection>: LoopIterator<Base> {

    public override func next() -> Base.Iterator.Element? {
        guard !collection.isEmpty else { return nil }

        defer {
            index = collection.index(after: index)
            if index == collection.endIndex { index = collection.startIndex }
        }

        return collection[index]
    }
}

public class ReverseLoopIterator<Base: Collection>: LoopIterator<Base> {

    public override func next() -> Base.Iterator.Element? {
        guard !collection.isEmpty else { return nil }

        defer {
            if index == collection.startIndex { index = collection.endIndex }

            let d = collection.distance(from: collection.startIndex, to: index)
            let e = (d + collection.count - 1) % collection.count

            index = collection.index(collection.startIndex, offsetBy: e)
        }

        return collection[index]
    }

}
