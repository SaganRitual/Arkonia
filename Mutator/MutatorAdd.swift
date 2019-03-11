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

    func copyAndReinsertReversed() -> [Gene]? {
        return copyAndReinsertSegment(.reversed)
    }

    func copyAndReinsertShuffled() -> [Gene]? {
        return copyAndReinsertSegment(.shuffled)
    }

    static var currentDynamicYScale = 0.0
    func copyAndReinsertSegment(_ preinsertAction: PreinsertAction) -> [Gene]? {
        outputGenome.removeAll(keepingCapacity: true)

        let (leftCut, rightCut) = getRandomSnipRange()
        let insertPoint = Int.random(in: 0..<sourceGenome.count)

        if !okToSnip(leftCut, rightCut) { return nil }

        let copiedSegment = sourceGenome[leftCut..<rightCut]
        var mutatedSegment = arrayPreinsertAction(preinsertAction, copiedSegment)
        if mutatedSegment.isEmpty { mutatedSegment = Array(copiedSegment) }

        let head = sourceGenome[..<insertPoint]
        let tail = sourceGenome[insertPoint...]

        outputGenome = head + mutatedSegment + tail

        return outputGenome
    }

    func arrayPreinsertAction(_ preinsertAction: PreinsertAction, _ strand: ArraySlice<Gene>) -> [Gene] {
        switch PreinsertAction.random() {
        case .doNothing: return [Gene]()
        case .reversed:  return strand.reversed()
        case .shuffled:  return strand.shuffled()
        }
    }

    func cutAndReinsertSegment(_ preinsertAction: PreinsertAction) -> [Gene]? {
        outputGenome.removeAll(keepingCapacity: true)

        let (leftCut, rightCut) = getRandomSnipRange()

        if !okToSnip(leftCut, rightCut) { return nil }

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

        return outputGenome
    }

    func insertRandomGenes() -> [Gene]? {
        outputGenome.removeAll(keepingCapacity: true)

        // Limit # of inserted genes to 10% of my length
        let cInsert_ = 0.1 * Double(sourceGenome.count) * Double(abs(bellCurve.nextFloat()))
        let cInsert = Int(cInsert_)
        if cInsert == 0 { return nil }

        outputGenome = sourceGenome

        (0..<cInsert).forEach { _ in
            let insertPoint = Int.random(in: 0..<sourceGenome.count)
            outputGenome.insert(Gene.makeRandomGene(), at: insertPoint)
        }

        return outputGenome
    }

    func insertRandomSegment() -> [Gene]? {
        outputGenome.removeAll(keepingCapacity: true)

        // Limit new segment to 10% of my length
        let cInsert_ = 0.1 * Double(sourceGenome.count) * Double(abs(bellCurve.nextFloat()))
        let cInsert = Int(cInsert_)
        if cInsert == 0 { return nil }

        let randomSegment = (0..<cInsert).map { _ in Gene.makeRandomGene() }
        let insertPoint = Int.random(in: 0..<sourceGenome.count)

        outputGenome = sourceGenome[..<insertPoint] + randomSegment + sourceGenome[insertPoint...]
        return outputGenome
    }

}

/*
 guard let histogram =
 DStatsPortal.shared.subportals[.seniorLabel]?.histogram as? SegmentMutationStatsHistogram
 else { preconditionFailure() }

 let length = cMutate
 let cZeros = Double(Int(log10(length)))
 let dynamicYScale = Double(exactly: pow(10.0, cZeros))!
 let rawValue = Int(floor(length / dynamicYScale))
 let fn = SegmentMutationStatsHistogram.StatType(rawValue: rawValue)!
 let zoomOut = dynamicYScale > Mutator.currentDynamicYScale

 histogram.accumulate(functionID: fn, zoomOut: zoomOut)

 if zoomOut { Mutator.currentDynamicYScale = dynamicYScale }
 */
