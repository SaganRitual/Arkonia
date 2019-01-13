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



class GChain {
    static var idNumber = 0
    let idNumber: Int

    weak var head: GChain?
    weak var tail: GChain?
    weak var prev: GChain?
    var next: GChain?

    var gene: Gene?

    var dCount = 0
    var uCount = 0

    init(_ gene: Gene) {
        idNumber = GChain.idNumber
        GChain.idNumber += 1

        self.gene = gene
    }

    static func == (_ lhs: GChain, _ rhs: GChain) -> Bool { return lhs.idNumber == rhs.idNumber }
}

// MARK: Insert

extension GChain {
    // There can't be an insert before, because it would mean
    // changing the head of the chain, which would require us
    // to return the new head.
    func insert(_ chain: GChain, after prev: GChain) {
        for link in makeIterator() {
            guard link == prev else { continue }
            let next = prev.next

            // Weak refs; order doesn't matter
            chain.prev = prev
            next?.prev = chain

            // Strong refs; grab next before prev lets go of it
            chain.next = next
            prev.next = chain
        }
    }

    func insert(_ chain: GChain, after: Int) {

    }
}

extension GChain: Sequence {
    typealias Iterator = GChainIterator

    struct GChainIterator: IteratorProtocol, Sequence {
        typealias Element = GChain

        private weak var chain: GChain?

        init(_ chain: GChain) { self.chain = chain }

        mutating func next() -> GChain? {
            guard var curr = chain else { return nil }
            defer { chain = curr.next }
            return curr
        }
    }

    func makeIterator() -> GChainIterator {
        return GChainIterator(self)
    }
}
