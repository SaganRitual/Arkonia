struct GridIndexer {
    enum LikeCSS { case right1, right2, bottom, left, top }

    let cCellsWithinSenseRange: Int
    let indexedGridPoints: UnsafeMutableBufferPointer<AKPoint>

    init(maxCSenseRings: Int) {
        let cCellsPerSide = 1 + 2 * maxCSenseRings
        self.cCellsWithinSenseRange = cCellsPerSide * cCellsPerSide

        self.indexedGridPoints = .allocate(capacity: cCellsWithinSenseRange)

        (0..<cCellsWithinSenseRange).forEach {
            self.indexedGridPoints[$0] = GridIndexer.makeIndexedGridPoint($0)
        }
    }

    func localIndexToGridPosition(_ center: AKPoint, _ localIx: Int) -> AKPoint {
        center + indexedGridPoints[localIx]
    }
}

private extension GridIndexer {
    static func _2xMinusOneSquared(_ x: Int) -> Int { ((2 * x) - 1) * ((2 * x) - 1) }

    static func getBaseX(_ index: Int) -> Int {
        if index == 0 { return 0 }

        var result = 0
        for x in 0... {
            if _2xMinusOneSquared(x) > index { result = x - 1; break }
        }

        return result
    }

    static func getExtent(_ x: Int) -> Int { x }
    static func getSide(_ x: Int) -> Int { 2 * x + 1 }

    //swiftlint:disable large_tuple
    static func stepDown(_ x: Int, _ y : Int, _ sideExtent: Int, _ whichSide_: LikeCSS) -> (Int, Int, LikeCSS) {
        var whichSide = whichSide_

        if y == -sideExtent {
            whichSide = .bottom
            return stepLeft(x, y, sideExtent, whichSide)
        }

        return (x + 0, y - 1, whichSide)
    }

    static func stepLeft(_ x: Int, _ y: Int, _ sideExtent: Int, _ whichSide_: LikeCSS) -> (Int, Int, LikeCSS) {
        var whichSide = whichSide_

        if x == -sideExtent {
            whichSide = .left
            return stepUp(x, y, sideExtent, whichSide)
        }

        return (x - 1, y + 0, whichSide)
    }

    static func stepUp(_ x: Int, _ y: Int, _ sideExtent: Int, _ whichSide_: LikeCSS) -> (Int, Int, LikeCSS) {
        var whichSide = whichSide_

        if y == sideExtent {
            whichSide = .top
            return stepRight(x, y, sideExtent, whichSide)
        }

        return (x + 0, y + 1, whichSide)
    }

    static func stepRight(_ x: Int, _ y: Int, _ sideExtent: Int, _ whichSide_: LikeCSS) -> (Int, Int, LikeCSS) {
        var whichSide = whichSide_

        if x == sideExtent && y == sideExtent {
            whichSide = .right2
            return stepDown(x, y, sideExtent, whichSide)
        }

        return (x + 1, y + 0, whichSide)
    }
    //swiftlint:enable large_tuple

    static func makeIndexedGridPoint(_ targetIndex: Int) -> AKPoint {
        if targetIndex == 0 { return AKPoint.zero }

        let baseX = getBaseX(targetIndex)
        var partialIndex = _2xMinusOneSquared(baseX)
        let sideExtent = getExtent(baseX)

        var x = baseX, y = 0
        var whichSide = LikeCSS.right1

        while partialIndex < targetIndex {
            switch whichSide {
            case .right1: fallthrough
            case .right2: (x, y, whichSide) =  stepDown(x, y, sideExtent, whichSide)

            case .bottom: (x, y, whichSide) =  stepLeft(x, y, sideExtent, whichSide)
            case .left:   (x, y, whichSide) =    stepUp(x, y, sideExtent, whichSide)
            case .top:    (x, y, whichSide) = stepRight(x, y, sideExtent, whichSide)
            }

            partialIndex += 1
        }

        return AKPoint(x: x, y: y)
    }
}
