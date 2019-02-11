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

    @discardableResult
    func cutRandomSegment() -> Segment? {
        let (leftCut, rightCut) = getRandomCuts(segmentLength: workingGenome.count)

        // This isn't correct, but I'm being lazy
        workingGenome.isCloneOfParent = false
        return cutSegment(leftCut, rightCut)
    }

    @discardableResult
    func cutSegment(_ leftCut: Int, _ rightCut: Int) -> Segment? {
        if !okToSnip(leftCut, rightCut) { return nil}

        // This isn't correct, but I'm being lazy
        workingGenome.isCloneOfParent = false
        return workingGenome.removeSubrange(leftCut..<rightCut)
    }

    func deleteRandomGenes() {
        if workingGenome.isEmpty { return }

        let cDelete = Double(abs(bellCurve.nextFloat())) * Double(workingGenome.count)
        if Int(cDelete) == 0 { return }

        let strideLength = workingGenome.count / Int(cDelete)
        for _ in stride(from: 0, to: workingGenome.count, by: strideLength) {
            let wherefore = Int.random(in: 0..<workingGenome.count)
            workingGenome.remove(at: wherefore)
            if workingGenome.isEmpty {
                // swiftlint:disable empty_count
                precondition(workingGenome.count == 0 && workingGenome.rcount == 0 && workingGenome.scount == 0)
                // swiftlint:enable empty_count
                break
            }
        }

        // This isn't correct, but I'm being lazy
        workingGenome.isCloneOfParent = false
    }
}
