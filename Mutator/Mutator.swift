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

    var histogramScale = 1.0

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

    func getWeightedRandomMutationType() -> MutationType {
        let weightMap: [MutationType : Int] = [
            .copyAndReinsertSegment : 6, .copyAndReinsertReversed: 3, .copyAndReinsertShuffled: 2,
            .cutAndReinsertSegment : 6, .cutAndReinsertReversed: 3, .cutAndReinsertShuffled: 2,
            .deleteRandomGenes : 3, .deleteRandomSegment : 3,
            .insertRandomGenes : 6, .insertRandomSegment : 6,
            .mutateRandomGenes : 10
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

    enum MutationType: CaseIterable {
        case copyAndReinsertSegment, copyAndReinsertReversed, copyAndReinsertShuffled
        case cutAndReinsertSegment, cutAndReinsertReversed, cutAndReinsertShuffled
        case deleteRandomGenes, deleteRandomSegment, insertRandomGenes, insertRandomSegment
        case mutateRandomGenes
    }

    // swiftlint:disable cyclomatic_complexity
    func mutate(_ sourceGenome: [Gene]) -> [Gene] {
        self.sourceGenome = sourceGenome
        self.outputGenome.removeAll(keepingCapacity: true)

        let m = getWeightedRandomMutationType()

        guard let mutatorHistogram =
            DStatsPortal.shared.subportals[.liveLabel]!.histogram as? MutatorStatsHistogram
            else { preconditionFailure() }

        mutatorHistogram.accumulate(functionID: m, zoomOut: false)

        switch m {
        case .deleteRandomGenes:           deleteRandomGenes()
        case .deleteRandomSegment:         cutRandomSegment()

        case .insertRandomGenes:           insertRandomGenes()
        case .insertRandomSegment:         insertRandomSegment()

        case .mutateRandomGenes:           mutateRandomGenes()

        case .cutAndReinsertSegment:       cutAndReinsertSegment(.doNothing)
        case .copyAndReinsertSegment:      copyAndReinsertSegment(.doNothing)
        case .cutAndReinsertReversed:      cutAndReinsertSegment(.reversed)
        case .copyAndReinsertReversed:     copyAndReinsertSegment(.reversed)
        case .cutAndReinsertShuffled:      cutAndReinsertSegment(.shuffled)
        case .copyAndReinsertShuffled:     copyAndReinsertSegment(.shuffled)
        }

        return self.outputGenome
    }
    // swiftlint:enable cyclomatic_complexity

    func mutate(from value: Double) -> Double {
        let m = Mutator.shared!
        let percentage = m.bellCurve.nextFloat()
        let v = (value == 0.0) ? Double.random(in: -1...1) : value
        let newValue = Double(1.0 - percentage) * v
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
    func mutateRandomGenes() {
        if sourceGenome.isEmpty { return }
        outputGenome = Array(sourceGenome)

        let m = Mutator.shared!
        let b = abs(m.bellCurve.nextFloat())
        var cMutate = 0.1 * Double(outputGenome.count) * Double(b)  // max 10% of genome
        precondition(abs(cMutate) != Double.infinity && cMutate != Double.nan)
        guard Int(cMutate) > 0 else { return }

        while cMutate > 0 {
            let wherefore = Int.random(in: 0..<outputGenome.count)
            _ = outputGenome[wherefore].mutate()
            cMutate -= 1
        }
    }
}
