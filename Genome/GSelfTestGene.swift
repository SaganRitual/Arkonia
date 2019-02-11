import Foundation

/**
 Internal self-test

 I want to test the internals of the class here, and let the
 unit tests do API-level testing.
 */
extension Genome {
    enum GenomeError: Error, Equatable {
        case ok
        case badData(_ line: Int, expected: [Int], actual: [Int])
        case corruptedStrand(_ line: Int)
        case expectedEmpty(_ line: Int)
        case expectedRelease(_ line: Int, expected: Int, actual: Int)
        case expectedMeaty(_ line: Int)
        case incorrectCount(_ line: Int, expected: Int, actual: Int)
    }

    static let testFunctions: [() -> GenomeError] = [
        geneInitTest, geneTest00A, geneTest01A, geneTest01B, geneTest02A, geneTest02B,
        geneTest02C, geneTest03A, geneTest03B, geneTest03C, geneTest03D,
        geneTest04A
    ]

    static func selfTest() -> GenomeError {
        for f in testFunctions.shuffled() {
            let e = f()
            if e != GenomeError.ok { return e }
        }

        return GenomeError.ok
    }

    static func validateEmptySegment(_ s: Segment) -> GenomeError {
        // swiftlint:disable empty_count
        guard s.head == nil && s.tail == nil && s.count == 0 else { return .corruptedStrand(#line) }
        // swiftlint:enable empty_count
        return .ok
   }

    static func validate(segmentWithOneGene s: Segment) -> GenomeError {
        guard let h = s.head, let t = s.tail else { return .corruptedStrand(#line) }
        guard h.isMyself(t) else { return .corruptedStrand(#line) }
        guard h.prev == nil && h.next == nil else { return .corruptedStrand(#line) }
        guard s.count == 1 else { return .corruptedStrand(#line) }
        return .ok
    }

    static func validate(segmentWithTwoGenes s: Segment) -> GenomeError {
        guard let h = s.head, let t = s.tail else { return .corruptedStrand(#line) }
        if h.isMyself(t) { return .corruptedStrand(#line) }
        guard h.prev == nil && t.next == nil else { return .corruptedStrand(#line) }
        guard let hn = h.next, let tp = t.prev else { return .corruptedStrand(#line) }
        guard hn.isMyself(t) && tp.isMyself(h) else { return .corruptedStrand(#line) }
        return .ok
    }

    static func validate(segmentWithThreeGenes s: Segment) -> GenomeError {
        guard let h = s.head, let t = s.tail else { return .corruptedStrand(#line) }
        if h.isMyself(t) { return .corruptedStrand(#line) }
        guard h.prev == nil && t.next == nil else { return .corruptedStrand(#line) }
        guard let hn = h.next, let tp = t.prev else { return .corruptedStrand(#line) }
        guard !hn.isMyself(t) && !tp.isMyself(h) else { return .corruptedStrand(#line) }
        guard hn.isMyself(tp) else { return .corruptedStrand(#line) }
        guard h.isMyself(hn.prev) else { return .corruptedStrand(#line) }
        guard t.isMyself(tp.next) else { return .corruptedStrand(#line) }
        return .ok
    }

    static func geneInitTest() -> GenomeError {
        var g = Genome()
        var v = validateEmptySegment(g)
        if v != .ok { return v }

        var expectedCallbackCount = 1
        var callbackCount = 0
        let cb = { callbackCount += 1 }

        g = Genome(gMockGene(42, destructorCallback: cb))
        v = validate(segmentWithOneGene: g)
        if v != .ok { return v }
        g.releaseFull_()    // Genes should destruct at this point
        if callbackCount != expectedCallbackCount { return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount) }

        callbackCount = 0
        expectedCallbackCount = 2
        g = Genome((0..<expectedCallbackCount).map({ gMockGene($0 + 42, destructorCallback: cb) }))
        v = validate(segmentWithTwoGenes: g)
        if v != .ok { return v }
        g.releaseFull_()
        if callbackCount != expectedCallbackCount { return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount) }

        callbackCount = 0
        expectedCallbackCount = 3
        g = Genome((0..<expectedCallbackCount).map({ gMockGene($0 + 42, destructorCallback: cb) }))
        v = validate(segmentWithThreeGenes: g)
        if v != .ok { return v }
        g.releaseFull_()
        if callbackCount != expectedCallbackCount { return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount) }

        callbackCount = 0
        expectedCallbackCount = 15
        g = Genome((0..<expectedCallbackCount).map({ gMockGene($0 + 42, destructorCallback: cb) }))
        let readBack = g.makeIterator().compactMap { gene in (gene as? gMockGene)?.value }
        if readBack != [Int](42..<(42 + expectedCallbackCount)) {
            return .badData(#line, expected: readBack, actual: [Int](42..<(42 + expectedCallbackCount)))
        }

        g.releaseFull_()    // Genes should destruct at this point
        if callbackCount != expectedCallbackCount { return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount) }

        return .ok
    }

    static func geneTest00A() -> GenomeError {
        let expectedCallbackCount = 1
        var callbackCount = 0
        let cb = { callbackCount += 1 }

        let g = Genome()
        g.inject(gMockGene(42, destructorCallback: cb), before: nil)

        let v = validate(segmentWithOneGene: g)
        if v != .ok { return v }
        g.releaseFull_()
        if callbackCount != expectedCallbackCount {
            return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount)
        }

        return .ok
    }

    static func geneTest01A() -> GenomeError {
        let expectedCallbackCount = 2
        var callbackCount = 0
        let cb = { callbackCount += 1 }

        let g = Genome(gMockGene(42, destructorCallback: cb))
        g.inject(gMockGene(42, destructorCallback: cb), before: 0)

        let v = validate(segmentWithTwoGenes: g)
        if v != .ok { return v }
        g.releaseFull_()
        if callbackCount != expectedCallbackCount {
            return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount)
        }

        return .ok
    }

    static func geneTest01B() -> GenomeError {
        let expectedCallbackCount = 2
        var callbackCount = 0
        let cb = { callbackCount += 1 }

        let g = Genome(gMockGene(42, destructorCallback: cb))
        g.inject(gMockGene(42, destructorCallback: cb), before: nil)

        let v = validate(segmentWithTwoGenes: g)
        if v != .ok { return v }
        g.releaseFull_()
        if callbackCount != expectedCallbackCount {
            return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount)
        }

        return .ok
    }

    static func geneTest02A() -> GenomeError {
        let expectedCallbackCount = 3
        var callbackCount = 0
        let cb = { callbackCount += 1 }

        let g = Genome(
            [gMockGene(42, destructorCallback: cb), gMockGene(42, destructorCallback: cb)]
        )

        g.inject(gMockGene(42, destructorCallback: cb), before: 0)

        let v = validate(segmentWithThreeGenes: g)
        if v != .ok { return v }
        g.releaseFull_()
        if callbackCount != expectedCallbackCount {
            return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount)
        }

        return .ok
    }

    static func geneTest02B() -> GenomeError {
        let expectedCallbackCount = 3
        var callbackCount = 0
        let cb = { callbackCount += 1 }

        let g = Genome(
            [gMockGene(42, destructorCallback: cb), gMockGene(42, destructorCallback: cb)]
        )

        g.inject(gMockGene(42, destructorCallback: cb), before: 1)

        let v = validate(segmentWithThreeGenes: g)
        if v != .ok { return v }
        g.releaseFull_()
        if callbackCount != expectedCallbackCount {
            return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount)
        }

        return .ok
    }

    static func geneTest02C() -> GenomeError {
        let expectedCallbackCount = 3
        var callbackCount = 0
        let cb = { callbackCount += 1 }

        let g = Genome(
            [gMockGene(42, destructorCallback: cb), gMockGene(42, destructorCallback: cb)]
        )

        g.inject(gMockGene(42, destructorCallback: cb), before: 2)

        let v = validate(segmentWithThreeGenes: g)
        if v != .ok { return v }
        g.releaseFull_()
        if callbackCount != expectedCallbackCount {
            return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount)
        }

        return .ok
    }

    static func geneTest03A() -> GenomeError {
        let expectedCallbackCount = 4
        var callbackCount = 0
        let cb = { callbackCount += 1 }

        let g = Genome([
            gMockGene(41, destructorCallback: cb), gMockGene(42, destructorCallback: cb),
            gMockGene(43, destructorCallback: cb)
        ])

        g.inject(gMockGene(44, destructorCallback: cb), before: g.head)

        let actual = g.makeIterator().compactMap { ($0 as? gMockGene)?.value }
        let expected = [44, 41, 42, 43]
        if actual != expected {
            return .badData(#line, expected: expected, actual: actual)
        }

        g.releaseFull_()
        if callbackCount != expectedCallbackCount {
            return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount)
        }

        return .ok
    }

    static func geneTest03B() -> GenomeError {
        let expectedCallbackCount = 4
        var callbackCount = 0
        let cb = { callbackCount += 1 }

        let g = Genome([
            gMockGene(41, destructorCallback: cb), gMockGene(42, destructorCallback: cb),
            gMockGene(43, destructorCallback: cb)
        ])

        g.inject(gMockGene(44, destructorCallback: cb), before: g.head?.next)

        let actual = g.makeIterator().compactMap { ($0 as? gMockGene)?.value }
        let expected = [41, 44, 42, 43]
        if actual != expected {
            return .badData(#line, expected: expected, actual: actual)
        }

        g.releaseFull_()
        if callbackCount != expectedCallbackCount {
            return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount)
        }

        return .ok
    }

    static func geneTest03C() -> GenomeError {
        let expectedCallbackCount = 4
        var callbackCount = 0
        let cb = { callbackCount += 1 }

        let g = Genome([
            gMockGene(41, destructorCallback: cb), gMockGene(42, destructorCallback: cb),
            gMockGene(43, destructorCallback: cb)
        ])

        g.inject(gMockGene(44, destructorCallback: cb), before: g.head?.next?.next)

        let actual = g.makeIterator().compactMap { ($0 as? gMockGene)?.value }
        let expected = [41, 42, 44, 43]
        if actual != expected {
            return .badData(#line, expected: expected, actual: actual)
        }

        g.releaseFull_()
        if callbackCount != expectedCallbackCount {
            return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount)
        }

        return .ok
    }

    static func geneTest03D() -> GenomeError {
        let expectedCallbackCount = 4
        var callbackCount = 0
        let cb = { callbackCount += 1 }

        let g = Genome([
            gMockGene(41, destructorCallback: cb), gMockGene(42, destructorCallback: cb),
            gMockGene(43, destructorCallback: cb)
        ])

        g.inject(gMockGene(44, destructorCallback: cb), before: g.head?.next?.next?.next)

        let actual = g.makeIterator().compactMap { ($0 as? gMockGene)?.value }
        let expected = [41, 42, 43, 44]
        if actual != expected {
            return .badData(#line, expected: expected, actual: actual)
        }

        g.releaseFull_()
        if callbackCount != expectedCallbackCount {
            return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount)
        }

        return .ok
    }

    static func geneTest04A() -> GenomeError {
        let expectedCallbackCount = 5
        var callbackCount = 0
        let cb = { callbackCount += 1 }

        let g = Genome([
            gMockGene(41, destructorCallback: cb), gMockGene(42, destructorCallback: cb),
            gMockGene(43, destructorCallback: cb), gMockGene(44, destructorCallback: cb)
        ])

        g.inject(gMockGene(40, destructorCallback: cb), before: 0)

        let actual = g.makeIterator().compactMap { ($0 as? gMockGene)?.value }
        let expected = [40, 41, 42, 43, 44]
        if actual != expected {
            return .badData(#line, expected: expected, actual: actual)
        }

        g.releaseFull_()
        if callbackCount != expectedCallbackCount {
            return .incorrectCount(#line, expected: expectedCallbackCount, actual: callbackCount)
        }

        return .ok
    }

}
