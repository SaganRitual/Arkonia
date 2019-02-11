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

// Makes it easier for me to reason about splicing and slicing
typealias Segment = Genome

class Genome: CustomDebugStringConvertible, GenomeProtocol {
    enum Caller { case count, head, tail }

    var count = 0
    var head: GeneLinkable?
    weak var tail: GeneLinkable?

    var rcount: Int {
        var rr = 0
        for _ in makeIterator() { rr += 1 }
        return rr
    }

    var scount: Int {
        var ss = 0, cc = head
        while let curr = cc {
            ss += 1
            cc = curr.next
        }

        return ss
    }

    var isCloneOfParent = true
    // swiftlint:disable empty_count
    var isEmpty: Bool { return count == 0 }
    // swiftlint:enable empty_count

    var debugDescription: String {
        return makeIterator().map { return String(reflecting: $0) + "\n" }.joined()
    }

    init() {}

    init(_ gene: GeneLinkable) { self.head = gene; self.tail = gene; count = 1 }
    init(_ genes: [GeneLinkable]) { genes.forEach { asslink($0) } }

    init(_ segment: Segment) { segment.releaseFull_(to: self) }
    init(_ segments: [Segment]) { segments.forEach { asslink($0) } }

    func dump() { makeIterator().forEach { print($0) } }
}

// MARK: Helpers

extension Genome {

    func contains(_ lookingForThisGene: GeneLinkable) -> Bool {
        for myGene in makeIterator() where myGene === lookingForThisGene {
            return true
        }

        return false
    }

    func copy(from: Int? = nil, to: Int? = nil) -> Segment {
        return Segment(makeIterator(from: from, to: to).map { $0.copy() })
    }

}

// MARK: subscript

extension Genome {

/**
     - Attention: On complexity:

 The doc for **Collection** (not `Sequence`) says that if you can't give O(1),
 then you need to document it
 clearly. Here I am, documenting it clearly, although I've decided not to use `Collection`,
 because it's giving me runtime fits over "differing counts in successive traversals", although
 I know the count is staying the same. Anyway, `Collection` doesnt buy us enough benefit to
 make it worth the trouble to track down and fix that problem. Subscripting will be very
 slow, and I use it a lot, but I don't
 think we do enough genome-grinding for it to matter. I'll profile it, and change the code if
 it turns out I'm wrong on that.

*/
    subscript (_ ss: Int) -> GeneLinkable {
        precondition(ss < count, "Subscript \(ss) out of range 0..<\(count)")

        var cc: Int? = 0
        for (c, gene) in zip(0..., makeIterator()) where c == ss { cc = ss; return gene }

        preconditionFailure("Fell through; ss = \(ss), c = \(cc ?? -42)")
    }
}

// MARK: Sequence - default iterator

// swiftlint:disable nesting

extension Genome: Sequence {
    struct GenomeIterator: IteratorProtocol, Sequence {
        typealias Iterator = GenomeIterator
        typealias Element = GeneLinkable

        private weak var gene: GeneLinkable?
        var primed = false

        let from: Int
        let to: Int

        init(_ genome: Genome, from: Int, to: Int) {
            self.gene = genome.head
            self.from = from
            self.to = to
        }

        mutating func next() -> GeneLinkable? {
            if !primed { prime() }
            guard var curr = gene else { return nil }
            defer { gene = curr.next }
            return curr
        }

        private mutating func prime() {
            primed = true

            (0..<from).forEach { _ in
                let s = self.next()
                self.gene = nok(s)
            }
        }
    }

    func makeIterator() -> GenomeIterator {
        return makeIterator(from: 0, to: self.count)
    }

    func makeIterator(from: Int? = nil, to: Int? = nil) -> GenomeIterator {
        return GenomeIterator(self, from: from ?? 0, to: to ?? self.count)
    }
}

// swiftlint:enable nesting

// MARK: Low-level link handling

extension Genome {
    func releaseFull_() { head = nil; tail = nil; count = 0 }

    func releaseFull_(to newOwner: Genome) {
        newOwner.head = self.head; newOwner.tail = self.tail; newOwner.count = self.count
        releaseFull_()
    }
}
