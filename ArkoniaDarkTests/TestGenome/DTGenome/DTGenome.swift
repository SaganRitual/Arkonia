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

class DTGenome: XCTestCase {
    func testGenome() {
        #if K_RUN_DT_GENOME
        print("K_RUN_DT_GENOME is set")
        #else
        XCTAssert(false)
        #endif

        func getGeneValues(_ segment: Segment) -> [Int] {
            return segment.map { return ($0 as! gMockGene).value }
        }

        // Smoke test
        let genome = Genome()
        XCTAssert(genome.isEmpty)
        XCTAssert(genome.count == 0)

        // Append one node at a time
        (0..<5).forEach {
            genome.asslink(gMockGene($0))
            XCTAssert(!genome.isEmpty)
            XCTAssertEqual(genome.count, $0 + 1)

            let gene = genome[$0] as? gMockGene
            XCTAssertNotNil(gene)
            XCTAssertEqual(gene!.value, $0)
        }

        XCTAssertEqual(genome.count, 5)

        // Init from array
        let genome2 = Genome((5..<15).map { return gMockGene($0) })
        XCTAssertEqual(genome2.count, 10)
        XCTAssertEqual(getGeneValues(genome2), [Int](5..<15))

        // Append full genome
        genome.asslink(genome2)
        XCTAssertEqual(genome.count, 15)

        // Remember, asslink() takes ownership of the genes
        XCTAssertEqual(genome2.count, 0)

        // Prepend a bunch of genes, make sure they link up
        // in the correct order
        (0..<10).forEach { genome2.headlink(gMockGene($0)) }
        var expectedOutput = Array([Int](0..<10).reversed())

        XCTAssertEqual(genome2.count, 10, "Inserted 10 genes but count != 10")
        XCTAssertEqual(getGeneValues(genome2), expectedOutput)

        // Prepend full genome
        genome.headlink(genome2)
        expectedOutput += Array([Int](0..<15))

        XCTAssertEqual(genome2.count, 0, "Target genome didn't take ownership")
        XCTAssertEqual(genome.count, 25, "Injected 10-gene into 15-gene; count s/b 25")
        XCTAssertEqual(getGeneValues(genome), expectedOutput)

        // Insert gene somewhere in the middle
        genome.inject(gMockGene(42), before: 19)
        expectedOutput.insert(42, at: 19)

        XCTAssertEqual(genome.count, 26, "Injected gene should raise count to 26")
        XCTAssertEqual(getGeneValues(genome), expectedOutput)

        // Append (array-initialized) segment to end
        XCTAssertEqual(genome.count, 26, "Injected gene should raise count to 26")
        let ass = Genome([Int](137..<150).map { return gMockGene($0) })
        genome2.asslink(ass)

        XCTAssertEqual(genome2.count, 13, "Asslinked genes should raise count to 13")
        XCTAssertEqual(getGeneValues(genome2), [Int](137..<150))

        // Inject segment
        genome.inject(genome2, before: 17)
        expectedOutput.insert(contentsOf: [Int](137..<150), at: 17)

        XCTAssertEqual(genome2.count, 0, "Target genome didn't take ownership")
        XCTAssertEqual(genome.count, 39, "13-gene injected to 26-gene s/b 39")
        XCTAssertEqual(getGeneValues(genome), expectedOutput)

        // Remove first
        genome.removeFirst()
        expectedOutput.removeFirst()

        XCTAssertEqual(genome.count, expectedOutput.count)
        XCTAssertEqual(getGeneValues(genome), expectedOutput)

        // Remove first n
        genome.removeFirst(5)
        expectedOutput.removeFirst(5)

        XCTAssertEqual(genome.count, expectedOutput.count)
        XCTAssertEqual(getGeneValues(genome), expectedOutput)

        // Remove last
        genome.removeLast()
        expectedOutput.removeLast()

        XCTAssertEqual(genome.count, expectedOutput.count)
        XCTAssertEqual(getGeneValues(genome), expectedOutput)

        // Remove last n
        genome.removeLast(7)
        expectedOutput.removeLast(7)

        XCTAssertEqual(genome.count, expectedOutput.count)
        XCTAssertEqual(getGeneValues(genome), expectedOutput)

        // Remove one from somewhere in the middle
        genome.removeOne(at: 19)
        expectedOutput.remove(at: 19)

        XCTAssertEqual(genome.count, expectedOutput.count)
        XCTAssertEqual(getGeneValues(genome), expectedOutput)

        // Remove multiple from somewhere in the middle
        genome.removeSubrange(7..<13)
        expectedOutput.removeSubrange(7..<13)

        XCTAssertEqual(genome.count, expectedOutput.count)
        XCTAssertEqual(getGeneValues(genome), expectedOutput)

        // Remove by predicate
        genome.removeAll { ($0 as! gMockGene).value > 100 }
        expectedOutput.removeAll { $0 > 100 }

        XCTAssertEqual(genome.count, expectedOutput.count)
        XCTAssertEqual(getGeneValues(genome), expectedOutput)

        // Build back up for snippet testing
        genome.asslink(Genome((200..<300).map { return gMockGene($0) }))
        expectedOutput.append(contentsOf: [Int](200..<300))

        XCTAssertEqual(genome.count, expectedOutput.count)
        XCTAssertEqual(getGeneValues(genome), expectedOutput)

        // Copy
        let genome3 = genome.copy()

        XCTAssertEqual(genome3.count, expectedOutput.count)
        XCTAssertEqual(getGeneValues(genome3), expectedOutput)

        genome.removeAll()

        XCTAssert(genome.isEmpty)
        XCTAssert(genome.count == 0)

        // What we're ensuring here is that genome3 got its own
        // copy of all the genes, such that it's not affected in
        // any way when genome releases all its genes.
        XCTAssertEqual(genome3.count, expectedOutput.count)
        XCTAssertEqual(getGeneValues(genome3), expectedOutput)

        // Found this one in the wild: inject() inserts before
        // the ss, so the only way to insert at the end is to
        // specify the (otherwise invalid) eof index. But we pass
        // that index to the subscript function, which of course
        // chokes on it.
        let count = genome3.count
        genome.asslink(genome3.copy())
        genome.inject(genome3, before: genome.count)

        // Check that genome3 has released his segment, and
        // genome has taken proper ownership of it.
        XCTAssertEqual(genome.count, count * 2)
        XCTAssert(!genome.isEmpty)
        XCTAssertEqual(genome3.count, 0)
        XCTAssert(genome3.isEmpty)

        // Another one from the wild. Remove the head element (!!). I'm shocked
        // this never showed up in testing.
        let strideLength = 4
        for _ in stride(from: 0, to: genome.count, by: strideLength) {
            genome.removeOne(at: 0)
            XCTAssertEqual(genome.count, genome.rcount, "\(genome.scount)")
        }
    }

}
