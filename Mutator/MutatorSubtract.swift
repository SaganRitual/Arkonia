import Foundation

infix operator &&=
func &&= (_ lhs: inout Bool, _ rhs: Bool) { lhs = lhs && rhs }

extension Mutator {

    @discardableResult
    func cutRandomSegment() -> ([GeneProtocol], [GeneProtocol])? {
        let (leftCut, rightCut) = getRandomCuts(segmentLength: sourceGenome.count)
        if !okToSnip(leftCut, rightCut) { return nil }

        outputGenome.removeAll(keepingCapacity: true)
        outputGenome.append(contentsOf: sourceGenome[..<leftCut])
        outputGenome.append(contentsOf: sourceGenome[rightCut...])

        return (outputGenome, Array(sourceGenome[leftCut..<rightCut]))
    }

    func deleteRandomGenes() -> ([GeneProtocol], [GeneProtocol])? {
        outputGenome.removeAll(keepingCapacity: true)

        let b = abs(self.bellCurve.nextFloat())
        let cDelete = 0.1 * Double(sourceGenome.count) * Double(b)  // max 10% of genome
        precondition(abs(cDelete) != Double.infinity && cDelete != Double.nan)
        guard Int(cDelete) > 0 else { return nil }

        outputGenome = sourceGenome.filter { _ in
            Double.random(in: 0..<cDelete) > (cDelete / Double(sourceGenome.count))
        }

        return (outputGenome, [])
    }

}
