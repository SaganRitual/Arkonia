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
