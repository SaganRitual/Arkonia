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

// MARK: functions that add to the genome: insert and append

extension Genome {
    // Like append, but transfers ownership away from the segment object.
    func asslink(_ gene: GeneLinkable) { inject(gene, before: nil) }
    func asslink(_ segment: Segment) { inject(segment, before: nil) }
    func asslink(_ segments: [Segment]) { segments.forEach { inject($0, before: nil) } }

    // Like prepend, but transfers ownership away from the segment object.
    func headlink(_ gene: GeneLinkable) {
        // To insert multiple genes, create a segment
        precondition(gene.next == nil && gene.prev == nil)

        head?.prev = gene   // Safe, order doesn't matter
        gene.next = head    // Must happen before we set head to a new value
        head = gene

        count += 1

        // Since we're inserting only one gene, we change
        // the tail only if the target segment is empty.
        if tail == nil { tail = head }
    }

    func headlink(_ segment: Segment) {
        head?.prev = segment.tail

        segment.tail?.next = head
        head = segment.head

        count += segment.count

        segment.releaseGenes()  // Transfer ownership
    }

    // Like insert, but transfers ownership away from the segment object.
    // (Except this one, which takes only a gene, which presumes that
    // there is no segment object, just a single gene.)
    func inject(_ gene: GeneLinkable, before ss: Int) {
        switch ss {
        case 0:          headlink(gene)
        case self.count: asslink(gene)
        default:         inject(gene, before: self[ss])
        }
    }

    func inject(_ segment: Segment, before ss: Int) {
        switch ss {
        case 0:          headlink(segment)
        case self.count: asslink(segment)
        default:         inject(segment, before: self[ss])
        }
    }

    func inject(_ segment: Segment, before next_: GeneLinkable?) {
        // Both must be nil, or both non-nil
        precondition((head == nil) == (tail == nil))

        defer {
            count += segment.count
            segment.releaseGenes()
        }

        if head == nil {
            head = segment.head
            tail = segment.tail
            count = 0
            return
        }

        // Let nil mean the endIndex
        guard let next = next_ else {
            tail!.next = segment.head
            segment.head?.prev = tail       // Optional, to allow for injection of empty segment
            tail = segment.tail
            return
        }

        let prev = next.prev

        segment.head?.prev = prev
        next.prev = segment.tail

        segment.tail?.next = next
        prev?.next = segment.head
    }

    func inject(_ gene: GeneLinkable, before next_: GeneLinkable?) {
        // Both must be nil, or both non-nil
        precondition((head == nil) == (tail == nil))

        defer { count += 1 }

        if head == nil {
            head = gene
            tail = gene
            return
        }

        // Let nil mean the endIndex
        guard let next = next_ else {
            gene.prev = tail
            tail!.next = gene
            tail = gene
            return
        }

        let prev = next.prev

        // Weak refs; order doesn't matter
        gene.prev = prev
        next.prev = gene

        // Strong refs; grab next before prev lets go of it
        gene.next = next
        prev?.next = gene   // prev == nil happens when we're inserting before head
    }

}
