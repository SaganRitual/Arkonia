import Foundation
import SpriteKit

class GridCore {
    let cellDimensionsPix: CGSize
    let funkyCellsMultiplier: CGFloat?
    let gridDimensionsCells: AKSize
    let paddingPixels: CGSize
    let portalDimensionsPix: CGSize

    var theCells = [GridCell]()

    init(
        cellDimensionsPix: CGSize, portalDimensionsPix: CGSize,
        maxCSenseRings: Int, funkyCellsMultiplier: CGFloat?
    ) {
        self.funkyCellsMultiplier = funkyCellsMultiplier
        self.cellDimensionsPix = cellDimensionsPix
        self.portalDimensionsPix = portalDimensionsPix

        let wc_ = Int(floor(CGFloat(portalDimensionsPix.width) / cellDimensionsPix.width))
        let hc_ = Int(floor(CGFloat(portalDimensionsPix.height) / cellDimensionsPix.height))

        // Ensure odd width and height, such that (0, 0) is a cell at the
        // center of the grid, such that there are the same number of cells
        // above (0, 0) as below, and the same number of cells to the right as
        // to the left.
        let wc = wc_ - ((wc_ % 2) == 0 ? 1 : 0)
        let hc = hc_ - ((hc_ % 2) == 0 ? 1 : 0)

        self.gridDimensionsCells = AKSize(width: wc, height: hc)

        let gridSizePixels = self.gridDimensionsCells.asSize() * cellDimensionsPix.width
        self.paddingPixels = (self.portalDimensionsPix - gridSizePixels) / 2

        Debug.log {
            "Grid size = \(self.gridDimensionsCells)"
            + ", portalsize = \(self.portalDimensionsPix)"
            + ", gridSizePixels = \(gridSizePixels)"
            + ", paddingPixels = \(paddingPixels)"
        }

        postInit()
    }

    private func postInit() {
        let cCells = self.gridDimensionsCells.area()

        self.theCells.reserveCapacity(cCells)

        for cellAbsoluteIndex in 0..<cCells {
            let ap = gridPosition(of: cellAbsoluteIndex)
            let ic = GridCell(
                cellAbsoluteIndex, ap, paddingPixels, cellDimensionsPix.width, funkyCellsMultiplier
            )

            self.theCells.append(ic)
        }
    }
}

extension GridCore {
    func absoluteIndex(of point: AKPoint) -> Int {
        let halfHeight = gridDimensionsCells.height / 2
        let yy = halfHeight - point.y

        let halfWidth = gridDimensionsCells.width / 2
        return (yy * gridDimensionsCells.width) + (halfWidth + point.x)
    }

    func cellAt(_ absoluteIndex: Int) -> GridCell { theCells[absoluteIndex] }

    func cellAt(_ gridPoint: AKPoint) -> GridCell {
        cellAt(absoluteIndex(of: gridPoint))
    }

    func gridPosition(of index: Int) -> AKPoint {
        let halfWidth = gridDimensionsCells.width / 2
        let halfHeight = gridDimensionsCells.height / 2

        let y = halfHeight - (index / gridDimensionsCells.width)
        let x = (index % gridDimensionsCells.width) - halfWidth

        return AKPoint(x: x, y: y)
    }
}
