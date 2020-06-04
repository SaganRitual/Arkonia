import Foundation

struct EngagerSpec {
    let cCellsInRange: Int
    let center: AKPoint
    let onComplete: () -> Void
    let pad: UnsafeMutablePointer<IngridCellDescriptor>
}

class IngridCore {
    let cellDimensionsPix: CGSize
    let gridDimensionsCells: AKSize
    let portalDimensionsPix: CGSize

    let indexer: IngridIndexer
    let theGrid: UnsafeMutableBufferPointer<IngridCell>

    init(
        cellDimensionsPix: CGSize, portalDimensionsPix: CGSize,
        maxCSenseRings: Int, funkyCellsMultiplier: CGFloat?
    ) {
        self.indexer = .init(maxCSenseRings: maxCSenseRings)

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

        let cCells = wc * hc

        theGrid = .allocate(capacity: cCells)
        theGrid.initialize(repeating: IngridCell())

        for cellAbsoluteIndex in 0..<cCells {
            let ap = self.absolutePosition(of: cellAbsoluteIndex)
            let ic = IngridCell(
                cellAbsoluteIndex, ap, portalDimensionsPix.width, funkyCellsMultiplier
            )

            theGrid[cellAbsoluteIndex] = ic
        }
    }

    func absoluteIndex(of point: AKPoint) -> Int {
        let halfHeight = gridDimensionsCells.height / 2
        let yy = halfHeight - point.y

        let halfWidth = gridDimensionsCells.width / 2
        return (yy * gridDimensionsCells.width) + (halfWidth + point.x)
    }

    func absolutePosition(of index: Int) -> AKPoint {
        let halfWidth = gridDimensionsCells.width / 2
        let halfHeight = gridDimensionsCells.height / 2

        let y = halfHeight - (index / gridDimensionsCells.width)
        let x = (index % gridDimensionsCells.width) - halfWidth

        return AKPoint(x: x, y: y)
    }

    // In other words, check whether the specified point is out of bounds of
    // the grid, and if so, return the point on the other side of the grid,
    // a wrap-around like the old Atari game called Asteroids
    func correctForDisjunction(_ oldPoint: AKPoint) -> AKPoint? {
        let ax = abs(oldPoint.x), sx = (oldPoint.x < 0) ? -1 : 1
        let ay = abs(oldPoint.y), sy = (oldPoint.y < 0) ? -1 : 1

        let halfW = gridDimensionsCells.width / 2, halfH = gridDimensionsCells.height / 2
        var newX = oldPoint.x, newY = oldPoint.y

        func correct(_ a: Int, _ halfGrid: Int, _ new: Int, _ sign: Int) -> Int? {
            if a > halfGrid {
                let d = 2 * (a - halfGrid) - 1
                return -sign * (a - d)
            }

            return nil
        }

        if let nx = correct(ax, halfW, newX, sx) { newX = nx }
        if let ny = correct(ay, halfH, newY, sy) { newY = ny }

        let newPoint = AKPoint(x: newX, y: newY)
        return newPoint == oldPoint ? nil : newPoint
    }

    func disengage(
        pad: UnsafeMutablePointer<IngridCellDescriptor>, padCCells: Int,
        keepTheseCells absoluteIndices: [Int],
        _ callback: @escaping (IngridCell) -> Void
    ) {
        let aix: (Int) -> Int = { pad[$0].absoluteIndex }

        for padSS in (0..<padCCells) where !absoluteIndices.contains(aix(padSS)) {
            let cell = theGrid[aix(padSS)]

            cell.isLocked = false
            callback(cell)
        }
    }

    @discardableResult
    func engageSensorPad(_ engagerSpec: EngagerSpec) -> Bool {
        let centerIx = absoluteIndex(of: engagerSpec.center)

        // If someone else has my own cell locked, I can't do anything
        if self.theGrid[centerIx].isLocked { return false }

        for ss in (0..<engagerSpec.cCellsInRange) {

            var isDisjunct = false
            var p = self.indexer.getGridPointByLocalIndex(center: engagerSpec.center, targetIndex: ss)

            if let q = self.correctForDisjunction(p) { p = q; isDisjunct = true }

            let cell = self.getCell(at: p)
            let iOwnTheLock = !cell.isLocked
            let requiresTeleportation = isDisjunct
            let c: IngridCell? = iOwnTheLock ? cell : nil

            c?.isLocked = true

            engagerSpec.pad[ss] = IngridCellDescriptor(c, cell.absoluteIndex, requiresTeleportation)
        }

        return true
    }

    func getCell(at point: AKPoint) -> IngridCell { theGrid[absoluteIndex(of: point)] }
}
