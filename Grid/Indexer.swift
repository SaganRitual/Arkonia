extension GridCell {
    func getGridPointByIndex(_ targetIndex: Int) -> AKPoint {
        return GridCell.getGridPointByIndex(center: gridPosition, targetIndex: targetIndex)
    }

    static func getGridPointByIndex(center: AKPoint, targetIndex: Int) -> AKPoint {
        precondition(targetIndex < Arkonia.cSenseGridlets)

        return [
            AKPoint(x: +0, y: +0),

            AKPoint(x: +1, y: +0), AKPoint(x: +1, y: -1), AKPoint(x: +0, y: -1),
            AKPoint(x: -1, y: -1), AKPoint(x: -1, y: +0), AKPoint(x: -1, y: +1),
            AKPoint(x: +0, y: +1), AKPoint(x: +1, y: +1),

            AKPoint(x: +2, y: +0), AKPoint(x: +2, y: -1), AKPoint(x: +2, y: -2), AKPoint(x: +1, y: -2), AKPoint(x: +0, y: -2),
            AKPoint(x: -1, y: -2), AKPoint(x: -2, y: -2), AKPoint(x: -2, y: -1), AKPoint(x: -2, y:  0), AKPoint(x: -2, y: -1),
            AKPoint(x: -2, y: +2), AKPoint(x: -1, y: +2), AKPoint(x: +0, y: +2), AKPoint(x: +1, y: +2), AKPoint(x: +2, y: +2), AKPoint(x: +2, y: +1),

            AKPoint(x: +3, y: +0), AKPoint(x: +3, y: -1), AKPoint(x: +3, y: -2), AKPoint(x: +3, y: -3), AKPoint(x: +2, y: -3), AKPoint(x: +1, y: -3), AKPoint(x: +0, y: -3),
            AKPoint(x: -1, y: -3), AKPoint(x: -2, y: -3), AKPoint(x: -3, y: -3), AKPoint(x: -3, y: -2), AKPoint(x: -3, y: -1), AKPoint(x: -3, y: +0), AKPoint(x: -3, y: +1),
            AKPoint(x: -3, y: +2), AKPoint(x: -3, y: +3), AKPoint(x: -2, y: +3), AKPoint(x: -1, y: +3), AKPoint(x: +0, y: +3), AKPoint(x: +1, y: +3), AKPoint(x: +2, y: +3),
            AKPoint(x: +3, y: +3), AKPoint(x: +3, y: +2), AKPoint(x: +3, y: +1)
        ][targetIndex] + center
    }
}
