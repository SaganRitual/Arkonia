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

    func copyAndReinsertReversed() {
        copyAndReinsertSegment(.reversed)
    }

    func copyAndReinsertShuffled() {
        copyAndReinsertSegment(.shuffled)
    }

    static var currentDynamicYScale = 0.0
    func copyAndReinsertSegment(_ preinsertAction: PreinsertAction) {
        let (leftCut, rightCut) = getRandomSnipRange()
        let insertPoint = Int.random(in: 0..<sourceGenome.count)

        if !okToSnip(leftCut, rightCut) { return }

        outputGenome.removeAll(keepingCapacity: true)

        let copiedSegment = sourceGenome[leftCut..<rightCut]
        let mutatedSegment = arrayPreinsertAction(preinsertAction, copiedSegment)

        let head = sourceGenome[..<insertPoint]
        let tail = sourceGenome[insertPoint...]

        guard let histogram =
            DStatsPortal.shared.subportals[.seniorLabel]?.histogram as? SegmentMutationStatsHistogram
                else { preconditionFailure() }

        let length = Double(rightCut - leftCut)
        let cZeros = Double(Int(log10(length)))
        let dynamicYScale = Double(exactly: pow(10.0, cZeros))!
        let rawValue = Int(length / dynamicYScale)
        let fn = SegmentMutationStatsHistogram.StatType(rawValue: rawValue)!
        let zoomOut = dynamicYScale > Mutator.currentDynamicYScale

        histogram.accumulate(functionID: fn, zoomOut: zoomOut)

        outputGenome = head + mutatedSegment + tail

        if zoomOut { Mutator.currentDynamicYScale = dynamicYScale }
    }

    func arrayPreinsertAction(_ preinsertAction: PreinsertAction, _ strand: ArraySlice<Gene>) -> [Gene] {
        switch PreinsertAction.random() {
        case .doNothing: return [Gene]()
        case .reversed:  return strand.reversed()
        case .shuffled:  return strand.shuffled()
        }
    }

    func cutAndReinsertSegment(_ preinsertAction: PreinsertAction) {
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

            let LRSegment = arrayPreinsertAction(preinsertAction, sourceGenome[leftCut..<rightCut])
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
