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
    func removeAll() { self.head = nil }

    func removeAll(where predicate: (Element) throws -> Bool) rethrows {
        var iter_: Gene? = self.head

        while let iter = iter_ {
            let next = iter.next

            defer { iter_ = next }

            if try !predicate(iter) { continue }

            if iter == self.head! { self.head = next }

            iter.prev?.next = next
            next?.prev = iter.prev

            count -= 1
        }
    }

    @discardableResult
    func removeFirst() -> Gene? {
        guard let first = head else { return nil }
        precondition(first.prev == nil, "Segment is corrupted")

        head = head?.next
        head?.prev = nil
        first.next = nil

        self.count -= 1

        if head == nil { tail = nil }

        return first
    }

    @discardableResult
    func removeFirst(_ k: Int) -> Segment {
        precondition(k < count, "Subscript out of range")

        let newHead = self[k]

        let firstK = Segment()
        firstK.head = self.head
        firstK.tail = self[k - 1]
        firstK.tail!.next = nil
        firstK.count = k

        newHead.prev = nil
        self.head = newHead
        self.count -= k

        if head == nil { tail = nil }

        return firstK
    }

    @discardableResult
    func removeLast() -> Gene? {
        guard let last = tail else { return nil }
        precondition(last.next == nil, "Segment is corrupted")

        tail = tail?.prev
        last.prev = nil
        tail?.next = nil    // Transfer ownership

        if tail == nil { head = nil }

        self.count -= 1

        return last
    }

    @discardableResult
    func removeLast(_ k: Int) -> Segment {
        precondition(k < count, "Subscript out of range")
        precondition(self.tail?.next == nil, "Segment is corrupted")

        let lastK = Segment()
        lastK.head = self[count - k]

        self.tail = lastK.head!.prev
        self.tail?.next = nil    // Release ownership of the new segment

        lastK.head!.prev = nil
        lastK.tail = self.tail
        lastK.count = k

        self.tail?.next = nil// remove

        if tail == nil { head = nil }

        self.count -= k

        return lastK
    }

    @discardableResult
    func removeOne(at ss: Int) -> Gene {
        precondition(ss < self.count, "Subscript out of range")
        return removeOne(gene: self[ss])
    }

    @discardableResult
    func removeOne(gene: Gene) -> Gene {
        let leftCut = gene.prev
        let rightCut = gene.next

        gene.next = nil
        gene.prev = nil

        leftCut?.next = rightCut
        rightCut?.prev = leftCut
        count -= 1

        return gene
    }

    @discardableResult
    func removeSubrange(_ r: Range<Int>) -> Segment {
        precondition(r.count <= self.count, "Subscript out of range")
        precondition(self.tail?.next == nil, "Genome corrupted")

        guard let ssFirst = r.first else { preconditionFailure("Should never happen?") }
        guard let ssLast = r.last else { preconditionFailure("Should never happen?") }

        let first = self[ssFirst]
        let last = self[ssLast]

        let segment = Segment()
        segment.head = first
        segment.tail = last
        segment.count = r.count

        let leftCut = first.prev
        let rightCut = last.next

        leftCut?.next = rightCut
        rightCut?.prev = leftCut
        count -= r.count

        return segment
    }
}
