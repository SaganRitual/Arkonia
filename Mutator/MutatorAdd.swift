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
        let (leftCut, rightCut) = getRandomSnipRange()
        let insertPoint = Int.random(in: 0..<sourceGenome.count)

        if !okToSnip(leftCut, rightCut) { return }

        outputGenome.removeAll(keepingCapacity: true)

        let copiedSegment = sourceGenome[leftCut..<rightCut]
        let mutatedSegment = arrayPreinsertAction(copiedSegment)

        let head = sourceGenome[..<insertPoint]
        let tail = sourceGenome[insertPoint...]

        outputGenome = head + mutatedSegment + tail
    }

    func arrayPreinsertAction(_ strand: ArraySlice<Gene>) -> [Gene] {
        switch PreinsertAction.random() {
        case .doNothing: return Array(strand)
        case .reverse:   return strand.reversed()
        case .shuffle:   return strand.shuffled()
        }
    }

    func cutAndReinsertSegment() {
        outputGenome.removeAll(keepingCapacity: true)

        let (leftCut, rightCut) = getRandomSnipRange()

        if !okToSnip(leftCut, rightCut) { return }

        let insertPoint = Int.random(in: 0..<sourceGenome.count)

        if insertPoint > (rightCut + 1) &&
            rightCut < sourceGenome.count &&
            insertPoint < sourceGenome.count
        {
            let tailSegment = sourceGenome[insertPoint...]
            let RISegment = sourceGenome[rightCut..<insertPoint]

            let LRSegment = arrayPreinsertAction(sourceGenome[leftCut..<rightCut])
            let headSegment = sourceGenome[..<leftCut]

            outputGenome = headSegment + RISegment + LRSegment + tailSegment
        }
    }

    func insertRandomGenes() {
        let cDelete = Double(abs(bellCurve.nextFloat())) * Double(sourceGenome.count)
        if Int(cDelete) == 0 { return }

        outputGenome.removeAll(keepingCapacity: true)

        var startIndex = sourceGenome.startIndex
        var endIndex = sourceGenome.startIndex

        while startIndex != endIndex {
            let segmentLength = Int.random(in: startIndex..<sourceGenome.endIndex)

            endIndex = sourceGenome.index(before: segmentLength - 1)

            outputGenome.append(contentsOf: sourceGenome[startIndex..<endIndex])
            outputGenome.append(Gene.makeRandomGene())

            startIndex = outputGenome.index(after: segmentLength)
        }
    }

    func insertRandomSegment() {
        let cDelete = Double(abs(bellCurve.nextFloat())) * Double(sourceGenome.count)
        if Int(cDelete) == 0 { return }

        outputGenome.removeAll(keepingCapacity: true)

        var startIndex = sourceGenome.startIndex
        var endIndex = sourceGenome.startIndex

        while startIndex != endIndex {
            let segmentLength = Int.random(in: startIndex..<sourceGenome.endIndex)

            endIndex = sourceGenome.index(before: segmentLength - 1)

            outputGenome.append(contentsOf: sourceGenome[startIndex..<endIndex])
            outputGenome.append(Gene.makeRandomGene())

            startIndex = outputGenome.index(after: segmentLength)
        }
    }

}
