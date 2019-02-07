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

// MARK: functions that subtract from the genome: remove and friends

extension Genome {
    func removeAll() { setHead(nil) }

    func removeAll(where predicate: (Element) throws -> Bool) rethrows {
        var iter_: GeneLinkable? = self.head

        while let iter = iter_ {
            validateSegment(self, checkCounts: true, checkOwnership: true)
            let next = iter.next

            defer { iter_ = next }

            if try !predicate(iter) { continue }

            if iter.isMyself(self.head!) { setHead(next) }

            iter.prev?.next = next
            next?.prev = iter.prev

            count -= 1
            validateSegment(self, checkCounts: true, checkOwnership: true)
        }
    }

    @discardableResult
    func removeFirst() -> GeneLinkable? {
        guard let first = head else { preconditionFailure("Genome is empty") }

        validateSegment(self, checkCounts: true, checkOwnership: true)

        setHead(head?.next)
        head?.prev = nil
        first.next = nil

        self.count -= 1

        if head == nil { tail = nil }

        validateGene(first)
        validateSegment(self, checkCounts: true, checkOwnership: true)
        return first
    }

    @discardableResult
    func removeFirst(_ k: Int) -> Segment {
        precondition(k < count, "Subscript out of range")
        validateSegment(self, checkCounts: true, checkOwnership: true)

        let newHead = self[k]

        let firstK = Segment()
        firstK.setHead(self.head)
        firstK.tail = self[k - 1]
        firstK.tail!.next = nil
        firstK.count = k

        newHead.prev = nil
        setHead(newHead)
        self.count -= k

        if head == nil { tail = nil }

        validate(self, firstK)
        return firstK
    }

    @discardableResult
    func removeLast() -> GeneLinkable? {
        guard let last = tail else { preconditionFailure("Genome is empty") }
        validateSegment(self, checkCounts: true, checkOwnership: true)

        tail = tail?.prev
        last.prev = nil
        tail?.next = nil    // Transfer ownership

        if tail == nil { setHead(nil) }

        self.count -= 1

        validateGene(last)
        validateSegment(self, checkCounts: true, checkOwnership: true)
        return last
    }

    @discardableResult
    func removeLast(_ k: Int) -> Segment {
        precondition(k < count, "Subscript out of range")
        validateSegment(self, checkCounts: true, checkOwnership: true)

        let lastK = Segment()
        lastK.setHead(self[count - k])

        self.tail = lastK.head!.prev
        self.tail?.next = nil    // Release ownership of the new segment

        lastK.head!.prev = nil
        lastK.tail = self.tail
        lastK.count = k

        self.tail?.next = nil// remove

        if tail == nil { setHead(nil) }

        self.count -= k

        validateSegment(self, checkCounts: true, checkOwnership: true)
        validateSegment(lastK, checkCounts: true, checkOwnership: true)
        return lastK
    }

    @discardableResult
    func removeOne(at ss: Int) -> GeneLinkable {
        precondition(ss < self.count, "Subscript out of range")
        return removeOne(gene: self[ss])
    }

    @discardableResult
    func removeOne(gene: GeneLinkable) -> GeneLinkable {
        // swiftlint:disable empty_count
        precondition(self.count != 0 && self.count == self.rcount && self.count == self.scount)
        // swiftlint:enable empty_count

        if gene.prev == nil { precondition(gene.isMyself(nok(self.head)), "Inconsistent head+gene") }
        if gene.next == nil { precondition(gene.isMyself(nok(self.tail)), "Inconsistent tail+gene") }
        if gene.prev != nil && gene.next != nil {
            precondition(!gene.isMyself(nok(self.head)) || !gene.isMyself(nok(self.tail)),
                         "Gene owned by another segment")

            if self.count > 1 {
                precondition(
                    !gene.isMyself(nok(self.head)) || !gene.isMyself(nok(self.tail)),
                    "c == 1 means head == gene == tail; c > 1 means gene " +
                    "should be in the middle somewhere"
                )
            }
        }

        validateSegment(self, checkCounts: true, checkOwnership: true)

        // Snip and release; order doesn't matter, because we have
        // the ref to the gene until we go out of scope
        gene.next?.prev = gene.prev
        gene.prev?.next = gene.next

        var subtractFromCount = 1

        // If we chopped the head, make a new head
        if let h = head, gene.isMyself(h) {
            setHead(gene.next)
            // Setting the head to hill will have set the count to
            // zero already, and we don't want to make it go negative
            // by attempting to subtract one from it for the removed gene.
            if head == nil { subtractFromCount = 0 }
        }

        // If we chopped the tail, make a new tail
        if let t = tail, gene.isMyself(t) { tail = gene.prev }

        gene.prev = nil     // Be tidy
        gene.next = nil     // Let go of the genome

        count -= subtractFromCount

        validateSegment(self, checkCounts: true, checkOwnership: true)
        return gene
    }

    @discardableResult
    func removeSubrange(_ r: Range<Int>) -> Segment {
        precondition(r.count <= self.count, "Subscript out of range")
        validateSegment(self, checkCounts: true, checkOwnership: true)

        guard let ssFirst = r.first else { preconditionFailure("Should never happen?") }
        guard let ssLast = r.last else { preconditionFailure("Should never happen?") }

        let first = self[ssFirst]
        let last = self[ssLast]

        let segment = Segment()
        segment.setHead(first)
        segment.tail = last
        segment.count = r.count

        // Snip & splice owner
        first.prev?.next = last.next
        last.next?.prev = first.prev

        if last.isMyself(nok(self.tail))  {
            self.tail = first.prev
            if tail == nil { setHead(nil) }
        } else {
            // Head observer takes care of the count
            if first.isMyself(nok(self.head)) { self.setHead(last.next) }
        }

        count -= r.count

        self.head?.prev = nil       // Be tidy
        self.tail?.next = nil       // Release ownership of the cut segment
        segment.head?.prev = nil    // Be tidy; prev is a weak link so this has no effect
        segment.tail?.next = nil    // Or of the original segment, if we took the head

        validate(self, segment)
        return segment
    }
}
