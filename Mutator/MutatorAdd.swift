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

extension Mutator {

    func copyAndReinsertSegment() {
        if workingGenome.isEmpty { return }

        let (leftCut, rightCut) = getRandomSnipRange()
        let insertPoint = Int.random(in: 0..<workingGenome.count)

        if !okToSnip(leftCut, rightCut) { return }

        let newStrand = workingGenome.copy(from: leftCut, to: rightCut)
        preinsertAction(newStrand)
        workingGenome.inject(newStrand, before: insertPoint)

        // This isn't correct, but I'm being lazy
        workingGenome.isCloneOfParent = false
    }

    func cutAndReinsertSegment() {
        if workingGenome.isEmpty { return }

        let (leftCut, rightCut) = getRandomSnipRange()

        if !okToSnip(leftCut, rightCut) { return }

        precondition(workingGenome.scount == workingGenome.count && workingGenome.rcount == workingGenome.count)

        let insertPoint = Int.random(in: 0..<workingGenome.count)

        // Who knew it would be so complicated?
        if insertPoint > rightCut && rightCut < workingGenome.count &&
            rightCut != insertPoint - 1 && insertPoint < workingGenome.count
        {
            let tailSegment = workingGenome.removeLast(workingGenome.count - insertPoint + 1)
            let RISegment = workingGenome.removeLast(workingGenome.count - rightCut)
            let LRSegment = workingGenome.removeLast(workingGenome.count - leftCut)
            preinsertAction(LRSegment!)

            workingGenome.asslink(Segment([RISegment!, LRSegment!, tailSegment!]))
        }

        precondition(workingGenome.scount == workingGenome.count && workingGenome.rcount == workingGenome.count)

        // This isn't technically correct, but I'm being lazy
        workingGenome.isCloneOfParent = false
    }

    func insertRandomGenes() {
        if workingGenome.isEmpty { return }

        let cInsert = Double(abs(bellCurve.nextFloat())) * Double(workingGenome.count)
        guard Int(cInsert) > 0 else { return }

        let strideLength = workingGenome.count / Int(cInsert)
        stride(from: 0, to: workingGenome.count, by: strideLength).forEach { _ in
            let newGene = Gene.makeRandomGene()
            let wherefore = Int.random(in: 0..<workingGenome.count)
            workingGenome.inject(newGene, before: wherefore)
        }

        // This isn't correct, but I'm being lazy
        workingGenome.isCloneOfParent = false
    }

    func insertRandomSegment() {
        let segment = Segment()

        let length = workingGenome.count / 10
        guard length > 0 else { return }

        let cGenes = Int.random(in: 0..<length)
        (0..<cGenes).forEach { _ in
            let newGene = Gene.makeRandomGene()
            segment.asslink(newGene)
        }

        // Notice: closed range, including one past the end. Doc says
        // you must use a valid index, but then says the endIndex value
        // is legal too. I guess that's how you can insert anywhere into
        // the workingGenome. The "at" parameter should be called "before". We're
        // inserting before "insertPoint".
        let insertPoint = Int.random(in: 0...workingGenome.count)
        insertSegment(segment, before: insertPoint)

        // This isn't correct, but I'm being lazy
        workingGenome.isCloneOfParent = false
    }

    func insertSegment(_ segment: Segment, before insertPoint: Int) {
        workingGenome.inject(segment, before: insertPoint)

        // This isn't correct, but I'm being lazy
        workingGenome.isCloneOfParent = false
    }

    func preinsertAction(_ segment: Segment) {
        switch PreinsertAction.random() {
        case .reverse:
            let reversed = Segment()
            while !segment.isEmpty {
                let gene = segment.removeLast()!
                reversed.asslink(gene)
            }

            segment.releaseFull_()
            reversed.releaseFull_(to: segment)
            segment.isCloneOfParent = false

        case .shuffle:
            let shuffled = Segment()
            while !segment.isEmpty {
                let gene = segment.remove(at: Int.random(in: 0..<segment.count))
                shuffled.asslink(gene)
            }

            segment.releaseFull_()
            shuffled.releaseFull_(to: segment)
            segment.isCloneOfParent = false

        case .doNothing: fallthrough
        default:         break
        }
    }

}
