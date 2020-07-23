import Foundation

class GridCell: CustomDebugStringConvertible {
    let contents = GridCellContents()
    let lock = GridLock()
    let properties: GridCellProperties

    var debugDescription: String { "Cell at \(properties.gridPosition)" }

    init(
        _ absoluteIndex: Int, _ absolutePosition: AKPoint, _ paddingPixels: CGSize,
        _ cellSideInPix: CGFloat, _ funkyCellsMultiplier: CGFloat?
    ) {
        properties = .init(
            absoluteIndex, absolutePosition, paddingPixels,
            cellSideInPix, funkyCellsMultiplier
        )
    }
}

class GridCellContents {
    var arkon: Spindle?
    var manna: Manna?

    enum CellContents: Float {
        case invisible = 0, arkon = 1, empty = 2, manna = 3

        func asSenseData() -> Float { return self.rawValue / 4.0 }
    }

    func hasArkon() -> Bool { arkon != nil }
    func hasManna() -> Bool { manna != nil }

    var contents: CellContents {
        if hasArkon() { return .arkon }
        else if hasManna() { return .manna }

        return .empty
    }
}

struct GridCellProperties: CustomDebugStringConvertible {
    let gridAbsoluteIndex: Int
    let gridPosition: AKPoint
    let scenePosition: CGPoint

    static let zero = GridCellProperties(0, AKPoint.zero, CGSize.zero, 0, nil)

    let debugDescription: String

    init(
        _ absoluteIndex: Int, _ absolutePosition: AKPoint, _ paddingPixels: CGSize,
        _ cellSideInPix: CGFloat, _ funkyCellsMultiplier: CGFloat?
    ) {
        self.gridAbsoluteIndex = absoluteIndex
        self.gridPosition = absolutePosition

        debugDescription =
            String(format: "%04d:", gridAbsoluteIndex) + "\(gridPosition)"

        let sp = (self.gridPosition.asPoint() * cellSideInPix) //+ paddingPixels.asPoint()

        guard let fm = funkyCellsMultiplier else {
            self.scenePosition = sp; return
        }

        // Set a random position on the display for this cell, slightly
        // offset from the center of the cell, just so Arkonia won't look
        // like a boring old rectilinear grid
        let wScene = cellSideInPix / 2
        let hScene = cellSideInPix / 2

        let lScene = sp.x - wScene * fm
        let rScene = sp.x + wScene * fm
        let bScene = sp.y - hScene * fm
        let tScene = sp.y + hScene * fm

        self.scenePosition = CGPoint.random(
            xRange: lScene..<rScene, yRange: bScene..<tScene
        )
    }
}
