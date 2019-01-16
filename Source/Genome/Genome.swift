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

class Genome {
    var head: Gene? { didSet { if head == nil { tail = nil; count = 0 } } }

    weak var tail: Gene?

    var count = 0
    var isEmpty: Bool { return count == 0 }

    init() {}
    init(_ genes: [Gene]) { genes.forEach { asslink($0) } }
    init(_ segment: Segment) {
        self.head = segment.head
        self.tail = segment.tail
        self.count = segment.count

        // Take ownership
        segment.head = nil
    }

    func releaseGenes() { head = nil }
}

// MARK: copy

extension Genome {
    func copy() -> Segment {
        return Segment(makeIterator().map { $0.copy() })
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
    subscript (_ ss: Int) -> Gene {
        precondition(ss < count, "Subscript \(ss) out of range 0..<\(count)")
        for (c, gene) in zip(0..., makeIterator()) where c == ss {
            return gene
        }
        preconditionFailure("Concession to the compiler. Shouldn't occur.")
    }
}

// MARK: Sequence

extension Genome: Sequence {
    typealias Iterator = GenomeIterator

    struct GenomeIterator: IteratorProtocol, Sequence {
        typealias Element = Gene

        private weak var gene: Gene?

        init(_ genome: Genome) { self.gene = genome.head }

        mutating func next() -> Gene? {
            guard var curr = gene else { return nil }
            defer { gene = curr.next }
            return curr
        }
    }

    func makeIterator() -> GenomeIterator {
        return GenomeIterator(self)
    }
}

// MARK: Miscellaney

extension Genome {
    func dump() {
        makeIterator().forEach { print("\($0) ", terminator: "") }
        print()
    }
}
