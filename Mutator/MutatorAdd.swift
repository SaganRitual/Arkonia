import Foundation

extension Mutator {

    func copyAndReinsertReversed() -> ([GeneProtocol], [GeneProtocol])? {
        return copyAndReinsertSegment(.reversed)
    }

    func copyAndReinsertShuffled() -> ([GeneProtocol], [GeneProtocol])? {
        return copyAndReinsertSegment(.shuffled)
    }

    static var currentDynamicYScale = 0.0
    func copyAndReinsertSegment(_ preinsertAction: PreinsertAction)
        -> ([GeneProtocol], [GeneProtocol])?
    {
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

        return (outputGenome, mutatedSegment)
    }

    func arrayPreinsertAction(
        _ preinsertAction: PreinsertAction, _ strand: ArraySlice<GeneProtocol>
    ) -> [GeneProtocol] {
        switch PreinsertAction.random() {
        case .doNothing: return [GeneProtocol]()
        case .reversed:  return strand.reversed()
        case .shuffled:  return strand.shuffled()
        }
    }

    func cutAndReinsertSegment(_ preinsertAction: PreinsertAction)
        -> ([GeneProtocol], [GeneProtocol])?
    {
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
        } else {
            outputGenome = sourceGenome
        }

        return (outputGenome, [])
    }

    func insertRandomGenes() -> ([GeneProtocol], [GeneProtocol])? {
        outputGenome.removeAll(keepingCapacity: true)

        // Limit # of inserted genes to 10% of my length
        let b = abs(bellCurve.nextFloat())
        let cInsert_ = 0.1 * Double(sourceGenome.count) * Double(b)
        let cInsert = Int(cInsert_)
        if cInsert == 0 { return nil }

        outputGenome = sourceGenome

        (0..<cInsert).forEach { _ in
            let insertPoint = Int.random(in: 0..<sourceGenome.count)
            outputGenome.insert(GeneCore.makeRandomGene(), at: insertPoint)
        }

        return (outputGenome, [])
    }

    func insertRandomSegment() -> ([GeneProtocol], [GeneProtocol])? {
        outputGenome.removeAll(keepingCapacity: true)

        // Limit new segment to 10% of my length
        let b = abs(bellCurve.nextFloat())
        let cInsert_ = 0.1 * Double(sourceGenome.count) * Double(b)
        let cInsert = Int(cInsert_)
        if cInsert == 0 { return nil }

        let randomSegment = (0..<cInsert).map { _ in GeneCore.makeRandomGene() }
        let insertPoint = Int.random(in: 0..<sourceGenome.count)

        outputGenome = sourceGenome[..<insertPoint] + randomSegment + sourceGenome[insertPoint...]
        return (outputGenome, [])
    }

}
