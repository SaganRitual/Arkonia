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

class Mutator {
    static var shared: Mutator!

    var bellCurve = BellCurve()
    var outputGenome = [Gene]()
    var sourceGenome = [Gene]()

    func copySegment() -> [Gene] {
        let (leftCut, rightCut) = getRandomCuts(segmentLength: sourceGenome.count)

        return sourceGenome[leftCut..<rightCut].map { $0 }
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
        if sourceGenome.isEmpty { return (0, 0) }

        let (leftCut, rightCut) = getRandomCuts(segmentLength: sourceGenome.count)
        return fixOrder(leftCut, rightCut)
    }

    func getWeightedRandomMutationType() -> MutationType {
        let weightMap: [MutationType : Int] = [
            .deleteRandomGenes : 3, .deleteRandomSegment : 1,
            .insertRandomGenes : 6, .insertRandomSegment :6,
            .mutateRandomGenes : 20, .cutAndReinsertSegment : 6, .copyAndReinsertSegment : 6
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

    func mutate(_ sourceGenome: [Gene]) -> [Gene] {
        self.sourceGenome = sourceGenome
        self.outputGenome.removeAll(keepingCapacity: true)

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

        return self.outputGenome
    }

    func mutate(from value: Double) -> Double {
        let m = Mutator.shared!
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

    enum PreinsertAction: CaseIterable {
        case doNothing, reverse, shuffle

        static func random() -> PreinsertAction {
            return nok(PreinsertAction.allCases.randomElement())
        }
    }

}

extension Mutator {
    func mutateRandomGenes() {
        if sourceGenome.isEmpty { return }
        outputGenome = Array(sourceGenome)

        let m = Mutator.shared!
        let b = abs(m.bellCurve.nextFloat())
        var cMutate = Double(b) * Double(outputGenome.count)
        precondition(abs(cMutate) != Double.infinity && cMutate != Double.nan)
        guard Int(cMutate) > 0 else { return }

        while cMutate > 0 {
            let wherefore = Int.random(in: 0..<outputGenome.count)
            outputGenome[wherefore] = Gene.makeRandomGene()
            cMutate -= 1
        }
    }
}
