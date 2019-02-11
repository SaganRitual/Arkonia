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

import XCTest

// siftlint:disable function_body_length
class DTGenome: XCTestCase {
//    func testGene() {
//        var cDestruct = 0
//        var gene1: gMockGene? = gMockGene(42, destructorCallback: { cDestruct += 1 })
//        var gene2: gMockGene? = gMockGene(43, destructorCallback: { cDestruct += 1 })
//        var head: gMockGene? = gene1
//        var tail: gMockGene? = gene2
//
//        head?.next = gene2
//        tail?.prev = gene1
//
//        gene1 = nil
//        print("One-a", cDestruct, gene1 == nil)
//        gene2 = nil
//        print("One-b", cDestruct, gene2 == nil)
//        tail = nil
//        print("Two", cDestruct, tail == nil)
//        head = nil
//        print("Three", cDestruct, head == nil)
//
//    }

    func testGenome() {
        #if K_RUN_DT_GENOME
        print("K_RUN_DT_GENOME is set")
        #else
        XCTAssert(false)
        #endif

        let result = Genome.selfTest()
        switch result {
        case .ok: break

        case let .badData(line, expected, actual):
            XCTAssert(false, ".badData, expected \(expected), actual \(actual) on line \(line)")

        case let .corruptedStrand(line): fallthrough
        case let .expectedEmpty(line):   fallthrough
        case let .expectedMeaty(line):   XCTAssert(false, "\(result) on line \(line)")

        case let .expectedRelease(line, expected, actual):
            let s = ".expectedRelease, expected \(expected) deinits" +
                    ", got \(actual) on line \(line)"

            XCTAssert(false, s)

        case let .incorrectCount(line, expected, actual):
            XCTAssert(false, ".incorrectCount, expected \(expected), got \(actual) on line \(line)")
        }
    }

}
