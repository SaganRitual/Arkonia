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

class Mutator: MutatorProtocol {
    weak var workingGenome_: Genome?
    var workingGenome: Genome { return nok(workingGenome_) }

    var bellCurve = BellCurve()

    init() { ArkonCentralDark.mutator = self }

    func copySegment() -> Segment {
        let (leftCut, rightCut) = getRandomCuts(segmentLength: workingGenome.count)
        workingGenome.isCloneOfParent = false
        return workingGenome.copy(from: leftCut, to: rightCut)
    }

    func fixOrder(_ lhs: Int, _ rhs: Int) -> (Int, Int) {
        var left = lhs, right = lhs
        if lhs < rhs { right = rhs } else { left = rhs }
        return (left, right)
    }

    func getRandomCuts(segmentLength: Int) -> (Int, Int) {
        // okToSnip() function will catch this and discard it
        guard segmentLength > 0 else { return (0, 0) }

        var leftCut = Int.random(in: 0..<segmentLength)
        var rightCut = Int.random(in: 0..<segmentLength)

        (leftCut, rightCut) = fixOrder(leftCut, rightCut)

        return (leftCut, rightCut)
    }

    func getRandomSnipRange() -> (Int, Int) {
        if workingGenome.isEmpty { return (0, 0) }

        let (leftCut, rightCut) = getRandomCuts(segmentLength: workingGenome.count)
        return fixOrder(leftCut, rightCut)
    }

    func getWeightedRandomMutationType() -> MutationType {
        let weightMap: [MutationType : Int] = [
            .deleteRandomGenes : 1, .deleteRandomSegment : 1,
            .insertRandomGenes : 1, .insertRandomSegment : 1,
            .mutateRandomGenes : 10, .cutAndReinsertSegment : 1, .copyAndReinsertSegment : 1
        ]

        let weightRange = weightMap.reduce(0, { return $0 + $1.value })
        let randomValue = Int.random(in: 0..<weightRange)

        var runningTotal = 0
        for (key, value) in weightMap {
            runningTotal += value
            if runningTotal > randomValue { return key }
        }

        fatalError()
    }

    enum MutationType: Int {
        case insertRandomGenes, insertRandomSegment, deleteRandomGenes, deleteRandomSegment,
        cutAndReinsertSegment, copyAndReinsertSegment, mutateRandomGenes
    }

    func mutate() -> GenomeProtocol {
        let m = getWeightedRandomMutationType()

        switch m {
        case .deleteRandomGenes:           deleteRandomGenes()
        case .deleteRandomSegment:         cutRandomSegment()

        case .insertRandomGenes:           insertRandomGenes()
        case .insertRandomSegment:         insertRandomSegment()

        case .mutateRandomGenes:           mutateRandomGenes()

        case .cutAndReinsertSegment:       cutAndReinsertSegment()
        case .copyAndReinsertSegment:      copyAndReinsertSegment()
        }

        return workingGenome
    }

    func mutate(from value: Double) -> Double {
        let m = nok(ArkonCentralDark.mutator as? Mutator)
        let percentage = m.bellCurve.nextFloat()
        let v = (value == 0.0) ? Double.random(in: -1...1) : value
        return Double(1.0 - percentage) * v
    }

    func okToSnip(_ leftCut: Int, _ rightCut: Int) -> Bool {
        return !((leftCut == 0 && rightCut == 0) || leftCut == rightCut)
    }

    func okToSnip(_ leftCut: Int, _ rightCut: Int, insertPoint: Int) -> Bool {
        return
            okToSnip(leftCut, rightCut) &&
            (leftCut + insertPoint) < rightCut &&
            (leftCut..<rightCut).contains(insertPoint)
    }

    func setInputGenome(_ inputGenome: GenomeProtocol) -> MutatorProtocol {
        self.workingGenome_ = nok(inputGenome as? Genome)
        return self
    }

    enum PreinsertAction: CaseIterable {
        case doNothing, reverse, shuffle

        static func random() -> PreinsertAction {
            return nok(PreinsertAction.allCases.randomElement())
        }
    }

}

extension Mutator {
    func mutateRandomGenes() {
        if workingGenome.isEmpty { return }

        let m = nok(ArkonCentralDark.mutator as? Mutator)
        let cMutate = Double(abs(m.bellCurve.nextFloat())) * Double(workingGenome.count)
        guard Int(cMutate) > 0 else { return }

        precondition(workingGenome.count == workingGenome.rcount && workingGenome.count == workingGenome.scount)
        let strideLength = workingGenome.count / Int(cMutate)
        stride(from: 0, to: workingGenome.count, by: strideLength).forEach { _ in
            let wherefore = Int.random(in: 0..<workingGenome.count)
            let gene = nok(workingGenome[wherefore] as? Gene)
            if gene.mutate() { workingGenome.isCloneOfParent = false }
        }
    }
}
