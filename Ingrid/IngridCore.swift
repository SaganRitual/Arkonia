import Foundation
import SpriteKit

struct IngridCore {
    let cellDimensionsPix: CGSize
    let gridDimensionsCells: AKSize
    let portalDimensionsPix: CGSize

    let theGrid: UnsafeMutableBufferPointer<IngridCell?>

    init(
        cellDimensionsPix: CGSize, portalDimensionsPix: CGSize,
        maxCSenseRings: Int, funkyCellsMultiplier: CGFloat?
    ) {
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

        let cCells = self.gridDimensionsCells.area()

        theGrid = .allocate(capacity: cCells)
        theGrid.initialize(repeating: nil)

        let gridSizePixels = self.gridDimensionsCells.asSize() * cellDimensionsPix.width
        let paddingPixels = (self.portalDimensionsPix - gridSizePixels) / 2.0

        for cellAbsoluteIndex in 0..<cCells {
            let ap = absolutePosition(of: cellAbsoluteIndex)
            let ic = IngridCell(
                cellAbsoluteIndex, ap, paddingPixels, cellDimensionsPix.width, funkyCellsMultiplier
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

    func cellAt(_ absolutePosition: AKPoint) -> IngridCell {
        let ax = Ingrid.absoluteIndex(of: absolutePosition)
        return theGrid[ax]!
    }

    func cellAt(_ absoluteIndex: Int) -> IngridCell { theGrid[absoluteIndex]! }

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

    enum LineSet { case horizontal, vertical }

    func drawGridLines() {
        let halfW = gridDimensionsCells.width / 2, halfH = gridDimensionsCells.height / 2

        func drawSet(_ halfD1: Int, _ halfD2: Int, _ lineSet: LineSet) {
            for i in -halfD2..<halfD2 {
                let x1: Int, y1: Int, x2: Int, y2: Int

                switch lineSet {
                case .horizontal:
                    x1 = -halfD1; y1 = i; x2 = halfD1; y2 = i
                case .vertical:
                    x1 = i; y1 = -halfD1; x2 = i; y2 = halfD1
                }

                let start = cellAt(AKPoint(x: x1, y: y1)).scenePosition
                let end =   cellAt(AKPoint(x: x2, y: y2)).scenePosition

                let line = SpriteFactory.drawLine(from: start, to: end, color: .darkGray)
                ArkoniaScene.arkonsPortal.addChild(line)
            }
        }

        drawSet(halfW, halfH, .horizontal)
        drawSet(halfH, halfW, .vertical)
    }

    func drawGridIndicators() {
        let atlas = SKTextureAtlas(named: "Backgrounds")
        let texture = atlas.textureNamed("debug-rectangle-solid")

        let halfW = gridDimensionsCells.width / 2, halfH = gridDimensionsCells.height / 2

        for y in -halfH..<halfH {
            for x in -halfW..<halfW {
                let p = cellAt(AKPoint(x: x, y: y)).scenePosition
                let s = SKSpriteNode(texture: texture)
                s.position = p
                s.setScale(0.2)
                s.color = .darkGray
                s.colorBlendFactor = 1
                ArkoniaScene.arkonsPortal.addChild(s)
            }
        }
    }
}
