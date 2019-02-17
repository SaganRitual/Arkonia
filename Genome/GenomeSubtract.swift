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
    func removeAll() { releaseFull_() }

    func removeAll(where predicate: (Element) throws -> Bool) rethrows {
        var iter_: GeneLinkable? = self.head

        while let iter = iter_ {
            let next = iter.next

            defer { iter_ = next }

            if try !predicate(iter) { continue }

            if iter.isMyself(self.head) { removeFirst(); continue }

            iter.prev?.next = next
            next?.prev = iter.prev
            count -= 1
        }
    }

    @discardableResult
    func removeFirst() -> GeneLinkable? { return removeFirst(1)?[0] ?? nil }

    @discardableResult
    func removeFirst(_ k: Int) -> Segment? {

        precondition(k > 0)
        precondition(!self.isEmpty)
        precondition(k <= self.count, "Subscript out of range")

        // Release my entire strand to a new segment. 
        if k == self.count { return Segment(self) }

        let newHead = self[k]

        let firstK = Segment()
        firstK.head = self.head
        firstK.tail = self[k - 1]
        firstK.tail!.next = nil
        firstK.count = k

        newHead.prev = nil
        self.head = newHead
        self.count -= k

        return firstK
    }

    @discardableResult
    func removeLast() -> GeneLinkable? { return removeLast(1)?[0] ?? nil }

    @discardableResult
    func removeLast(_ k: Int) -> Segment? {

        precondition(k > 0)
        precondition(!self.isEmpty)
        precondition(k <= count, "Subscript out of range")

        // Release my entire strand to a new segment.
        if k == self.count { return Segment(self) }
        if self.count == 1 { return Segment(self) }

        let lastK = Segment()
        lastK.head = self[self.count - k]

        lastK.tail = self.tail          // K owns my old tail now
        self.tail = lastK.head?.prev    // I have a new tail

        lastK.head?.prev = nil          // K has a proper head now
        self.tail?.next = nil           // Release reference; now K owns the strand

        lastK.count = k
        self.count -= k

        return lastK
    }

    @discardableResult
    func remove(at ss: Int) -> GeneLinkable { return remove(gene: self[ss]) }

    @discardableResult
    func remove(gene: GeneLinkable) -> GeneLinkable {
        precondition(!self.isEmpty, "Can't remove gene from empty genome")
        precondition(self.contains(gene), "Gene not found in this genome")

        // Snip and release; order doesn't matter, because we have
        // the ref to the gene until we go out of scope
        gene.next?.prev = gene.prev
        gene.prev?.next = gene.next

        self.count -= 1

        if self.isEmpty { self.releaseFull_(); return gene }

        // If we chopped the head, make a new head
        if head?.isMyself(gene) ?? false {
            head?.prev = nil
            head = head?.next
        }

        // If we chopped the tail, make a new tail
        if tail?.isMyself(gene) ?? false {
            tail?.next = nil    // Transfer ownership
            tail = tail?.prev
        }

        gene.prev = nil     // Be tidy
        gene.next = nil     // Let go of the genome

        return gene
    }

    @discardableResult
    func removeSubrange(_ r: Range<Int>) -> Segment? {
        precondition(r.count <= self.count, "Subscript out of range")

        if r.isEmpty { return nil }

        guard let ssFirst = r.first else { preconditionFailure("Should never happen?") }
        guard let ssLast = r.last else { preconditionFailure("Should never happen?") }

        // Release my entire strand to a new segment.
        if ssFirst == 0 && ssLast == self.count { return Segment(self) }

        // If we're chopping one end, use a chopping function
        if ssFirst == 0 && ssLast <  self.count { return removeFirst(ssLast + 1) }
        if ssFirst > 0  && ssLast == self.count { return removeLast(ssLast - ssFirst) }

        // At this point, we know that we're removing a segment from
        // somewhere in the middle of my strand; neither my head nor
        // my tail is involved. This of course also means that my
        // strand is not empty.
        let first = self[ssFirst]
        let last = self[ssLast]

        let segment = Segment()
        segment.head = first
        segment.tail = last
        segment.count = ssLast - ssFirst

        // Snip & splice owner
        first.prev?.next = last.next
        last.next?.prev = first.prev
        self.count -= segment.count

        return segment
    }
}
