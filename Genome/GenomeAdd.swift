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

    // Like prepend, but transfers ownership away from the segment object.
    func headlink(_ gene: GeneLinkable) { inject(gene, before: self.head) }
    func headlink(_ segment: Segment) { inject(segment, before: self.head) }

    // Like insert, but transfers ownership away from the source segment object.
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

    func inject(_ gene: GeneLinkable, before next_: GeneLinkable?) {
        inject(Genome(gene), before: next_)
    }

    /**
     Take ownership of the segment's strand and insert it into my strand.

     - Parameters:
        - transport: The transporting segment. We take his entire strand,
                 and he goes away empty.
        - before: The gene (in my strand) before which to insert his. nil means
                insert at the end, ie, append his strand to mine.

     - Important: All the other additive calls route through here. That is,
                    they're convenience functions. This one is the nuts &
                    bolts. So don't go calling any of those others from here.

     - Important: We take ownership of the passed-in segment's strand. The
                    caller can still use the segment, but after we're finished,
                    his segment is empty until he puts something in it.
     */
    // swiftlint:disable function_body_length
    func inject(_ transport: Segment, before next_: GeneLinkable?) {
        if transport.isEmpty { return }
        if self.isEmpty { transport.releaseFull_(to: self); return }

        // I have a strand of at least one gene

        // Insert before nil means append
        guard let next = next_ else {
            switch (self.count, transport.count) {
            case (1, 1):
                self.head?.next = transport.head
                self.tail = transport.head
                self.tail?.prev = self.head
                self.count += 1
                transport.reset(releaseGenes: false)
                return

            case (1, 2...):
                self.tail = transport.tail
                self.head?.next = transport.head
                transport.head?.prev = self.head
                self.count += transport.count
                transport.reset(releaseGenes: false)
                return

            case (2..., 1):
                transport.tail?.prev = self.tail
                self.tail?.next = transport.tail
                self.tail = transport.tail
                self.count += 1
                transport.reset(releaseGenes: false)
                return

            case (2..., 2...):
                transport.head?.prev = self.tail
                self.tail?.next = transport.head
                self.tail = transport.tail
                self.count += transport.count

                transport.reset(releaseGenes: false)
                return

            default: preconditionFailure()
            }
        }

        // Insert before head
        if next.isMyself(self.head) {
            // Same here; I'm pretty sure the order of these operations
            // doesn't matter. Here, the transport is holding onto the
            // new strand, and the `next` variable is holding onto the
            // lower half of my strand while we splice in the new strand.
            self.head?.prev = transport.tail
            transport.tail?.next = self.head
            self.head = transport.head
            self.count += transport.count

            transport.reset(releaseGenes: false)
            return
        }

        // Insert point is not nil and not head; this is possible
        // only if we have at least two genes in the strand, and we're
        // inserting between two genes. A corollary of this is that we
        // need not change either head or tail.
        transport.head?.prev = next.prev
        next.prev?.next = transport.head
        next.prev = transport.tail
        transport.tail?.next = next
        count += transport.count

        transport.reset(releaseGenes: false)
    }
    // swiftlint:enable function_body_length

}
