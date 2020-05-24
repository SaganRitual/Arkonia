extension GridCell {
    enum LikeCSS { case right1, right2, bottom, left, top }

    static let indexedGridPoints: [AKPoint] = {
        let netStructure = NetStructure.makeNetStructure(cSenseRings: NetStructure.cSenseRingsRange.upperBound)
        return (0..<netStructure.cCellsWithinSenseRange).map {
            GridCell.makeIndexedGridPoint($0)
        }
    }()

    private static func _2xMinusOneSquared(_ x: Int) -> Int { ((2 * x) - 1) * ((2 * x) - 1) }

    private static func getBaseX(_ index: Int) -> Int {
        if index == 0 { return 0 }

        var result = 0
        for x in 0... {
            if _2xMinusOneSquared(x) > index { result = x - 1; break }
        }

        return result
    }

    private static func getExtent(_ x: Int) -> Int { x }
    private static func getSide(_ x: Int) -> Int { 2 * x + 1 }

    //swiftlint:disable large_tuple
    private static func stepDown(_ x: Int, _ y : Int, _ sideExtent: Int, _ whichSide_: LikeCSS) -> (Int, Int, LikeCSS) {
        var whichSide = whichSide_

        if y == -sideExtent {
            whichSide = .bottom
            return stepLeft(x, y, sideExtent, whichSide)
        }

        return (x + 0, y - 1, whichSide)
    }

    private static func stepLeft(_ x: Int, _ y: Int, _ sideExtent: Int, _ whichSide_: LikeCSS) -> (Int, Int, LikeCSS) {
        var whichSide = whichSide_

        if x == -sideExtent {
            whichSide = .left
            return stepUp(x, y, sideExtent, whichSide)
        }

        return (x - 1, y + 0, whichSide)
    }

    private static func stepUp(_ x: Int, _ y: Int, _ sideExtent: Int, _ whichSide_: LikeCSS) -> (Int, Int, LikeCSS) {
        var whichSide = whichSide_

        if y == sideExtent {
            whichSide = .top
            return stepRight(x, y, sideExtent, whichSide)
        }

        return (x + 0, y + 1, whichSide)
    }

    private static func stepRight(_ x: Int, _ y: Int, _ sideExtent: Int, _ whichSide_: LikeCSS) -> (Int, Int, LikeCSS) {
        var whichSide = whichSide_

        if x == sideExtent && y == sideExtent {
            whichSide = .right2
            return stepDown(x, y, sideExtent, whichSide)
        }

        return (x + 1, y + 0, whichSide)
    }
    //swiftlint:enable large_tuple

    func getGridPointByIndex(_ targetIndex: Int) -> AKPoint {
        return getGridPointByIndex(center: gridPosition, targetIndex: targetIndex)
    }

    func getGridPointByIndex(center: AKPoint, targetIndex: Int) -> AKPoint {
        return center + GridCell.indexedGridPoints[targetIndex]
    }

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

        Debug.log(level: 131) { "getGridPointByIndex(\(targetIndex)) -> \(AKPoint.zero) + (\(x), \(y)) = \(AKPoint(x: x, y: y))" }
        return AKPoint(x: x, y: y)
    }
}
