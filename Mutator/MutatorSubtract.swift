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
    func cutRandomSegment() -> [Gene]? {
        let (leftCut, rightCut) = getRandomCuts(segmentLength: sourceGenome.count)
        if !okToSnip(leftCut, rightCut) { return nil }

        outputGenome.removeAll(keepingCapacity: true)
        outputGenome.append(contentsOf: sourceGenome[..<leftCut])
        outputGenome.append(contentsOf: sourceGenome[rightCut...])

        return Array(sourceGenome[leftCut..<rightCut])
    }

    func deleteRandomGenes() {
        let cDelete = Double(abs(bellCurve.nextFloat())) * Double(sourceGenome.count)
        if Int(cDelete) == 0 { return }

        outputGenome.removeAll(keepingCapacity: true)

        var startIndex = sourceGenome.startIndex
        var endIndex = sourceGenome.startIndex

        while startIndex != endIndex {
            let segmentLength = Int.random(in: startIndex..<sourceGenome.endIndex)

            endIndex = sourceGenome.index(before: segmentLength - 1)

            outputGenome.append(contentsOf: sourceGenome[startIndex..<endIndex])

            startIndex = sourceGenome.index(after: segmentLength)
        }
    }

}
