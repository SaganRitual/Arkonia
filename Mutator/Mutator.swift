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
    var outputGenome = [GeneProtocol]()
    var sourceGenome = [GeneProtocol]()

    func copySegment() -> [GeneProtocol] {
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

        let bell = Double(abs(bellCurve.nextFloat()))
        let length = Double(rightCut - leftCut)

        // Never more than 10% of my genome
        let scaledLength = 0.1 * length * bell

        if scaledLength < length {
            rightCut -= Int((length - scaledLength) / 2)
            leftCut += Int((length - scaledLength) / 2)
        }

        return (leftCut, rightCut)
    }

    func getRandomSnipRange() -> (Int, Int) {
        if sourceGenome.isEmpty { return (0, 0) }

        let (leftCut, rightCut) = getRandomCuts(segmentLength: sourceGenome.count)
        return fixOrder(leftCut, rightCut)
    }

    enum MutationType: Int, CaseIterable {
        case copyAndReinsertSegment, copyAndReinsertReversed, copyAndReinsertShuffled
        case cutAndReinsertSegment, cutAndReinsertReversed, cutAndReinsertShuffled
        case deleteRandomGenes, deleteRandomSegment, insertRandomGenes, insertRandomSegment
        case mutateRandomGenes
    }

    // swiftlint:disable cyclomatic_complexity
    func mutate(_ sourceGenome: [GeneProtocol]) -> [GeneProtocol] {
        self.sourceGenome = sourceGenome
        self.outputGenome.removeAll(keepingCapacity: true)

        let m = nok(MutationType.allCases.randomElement())

        var newGenome: ([GeneProtocol], [GeneProtocol])?
        switch m {
        case .deleteRandomGenes:       newGenome = deleteRandomGenes()
        case .deleteRandomSegment:     newGenome = cutRandomSegment()

        case .insertRandomGenes:       newGenome = insertRandomGenes()
        case .insertRandomSegment:     newGenome = insertRandomSegment()

        case .mutateRandomGenes:       newGenome = mutateRandomGenes()

        case .cutAndReinsertSegment:   newGenome = cutAndReinsertSegment(.doNothing)
        case .copyAndReinsertSegment:  newGenome = copyAndReinsertSegment(.doNothing)
        case .cutAndReinsertReversed:  newGenome = cutAndReinsertSegment(.reversed)
        case .copyAndReinsertReversed: newGenome = copyAndReinsertSegment(.reversed)
        case .cutAndReinsertShuffled:  newGenome = cutAndReinsertSegment(.shuffled)
        case .copyAndReinsertShuffled: newGenome = copyAndReinsertSegment(.shuffled)
        }

        if newGenome == nil { outputGenome = sourceGenome }
        return outputGenome
    }
    // swiftlint:enable cyclomatic_complexity

    func mutate(from value: Double) -> Double {
        let percentage = bellCurve.nextFloat()
        let newValue = Double(1.0 - percentage) * value
        return newValue
    }

    func okToSnip(_ leftCut: Int, _ rightCut: Int) -> Bool {
        return leftCut > 0 && rightCut > leftCut
    }

    func okToSnip(_ leftCut: Int, _ rightCut: Int, insertPoint: Int) -> Bool {
        return
            okToSnip(leftCut, rightCut) &&
            (leftCut + insertPoint) < rightCut &&
            (leftCut..<rightCut).contains(insertPoint)
    }

    enum PreinsertAction: CaseIterable {
        case doNothing, reversed, shuffled

        static func random() -> PreinsertAction {
            return nok(PreinsertAction.allCases.randomElement())
        }
    }

}

extension Mutator {
    func mutateRandomGenes() -> ([GeneProtocol], [GeneProtocol])? {
        if sourceGenome.isEmpty { return nil }
        outputGenome.removeAll(keepingCapacity: true)
        outputGenome = sourceGenome

        let b = abs(bellCurve.nextFloat())
        var cMutate = 0.1 * Double(outputGenome.count) * Double(b)  // max 10% of genome
        precondition(abs(cMutate) != Double.infinity && cMutate != Double.nan)

        let i = Int(cMutate)
        guard i > 0 else { return nil }

        while cMutate > 0 {
            let wherefore = Int.random(in: 0..<outputGenome.count)
            outputGenome.insert(GeneCore.mutated(from: outputGenome[wherefore]), at: wherefore)
            cMutate -= 1
        }

        return (outputGenome, [])
    }
}
