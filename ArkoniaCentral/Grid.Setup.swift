import SpriteKit

extension Grid {
    func setupGrid(_ portal: SKSpriteNode, drawLines: Bool = false) {
        let d = Grid.dimensions!

        for x in stride(from: 0, to: d.wPortal, by: d.wSprite) where drawLines == true {
            if x != 0 { drawGridLine(portal, -x, -d.hPortal, -x, d.hPortal) }

            drawGridLine(portal, +x, -d.hPortal, +x, d.hPortal)
        }

        for y in stride(from: 0, to: d.hPortal - d.hSprite, by: d.hSprite) {
            let yGrid = y / d.hSprite

            if drawLines == true {
                if y != 0 { drawGridLine(portal, -d.wPortal, -y, d.wPortal, -y) }

                drawGridLine(portal, -d.wPortal, +y, d.wPortal, +y)
            }

            placeGridlet(y, yGrid)
        }
    }

    //swiftmint:disable function_body_length
    func placeGridlet(_ y: Int, _ yGrid: Int) {
        let d = Grid.dimensions!

        for x in stride(from: 0, to: d.wPortal - d.wSprite, by: d.wSprite) {
            let xGrid = x / d.wSprite

            switch (x, y) {
            case (0, 0):
                let p = AKPoint(x: xGrid, y: yGrid)
                Grid.cells[p] = GridCell(gridPosition: p, scenePosition: CGPoint.zero)

            case (_, 0):

                let p = AKPoint(x:  xGrid, y: yGrid)
                Grid.cells[p] = GridCell(gridPosition: p, scenePosition: CGPoint(x:  x, y: y))

                if xGrid < d.wGrid {
                    let q = AKPoint(x: -xGrid, y: yGrid)
                    Grid.cells[q] = GridCell(gridPosition: q, scenePosition: CGPoint(x: -x, y: y))
                }

            case (0, _):
                let p = AKPoint(x: xGrid, y:  yGrid)
                Grid.cells[p] = GridCell(gridPosition: p, scenePosition: CGPoint(x: x, y:  y))

                if yGrid < d.hGrid {
                    let q = AKPoint(x: xGrid, y: -yGrid)
                    Grid.cells[q] = GridCell(gridPosition: q, scenePosition: CGPoint(x: x, y: -y))
                }

            default:
                let p = AKPoint(x:  xGrid, y:  yGrid)
                Grid.cells[p] = GridCell(gridPosition: p, scenePosition: CGPoint(x:  x, y:  y))

                if xGrid < d.wGrid && yGrid < d.hGrid {
                    let s = AKPoint(x: -xGrid, y: -yGrid)

                    Grid.cells[s] = GridCell(gridPosition: s, scenePosition: CGPoint(x: -x, y: -y))
                }

                if xGrid < d.wGrid {
                    let q = AKPoint(x: -xGrid, y:  yGrid)
                    Grid.cells[q] = GridCell(gridPosition: q, scenePosition: CGPoint(x: -x, y:  y))
                }

                if yGrid < d.hGrid {
                    let r = AKPoint(x:  xGrid, y: -yGrid)
                    Grid.cells[r] = GridCell(gridPosition: r, scenePosition: CGPoint(x:  x, y: -y))
                }
            }
        }
    }
    //swiftmint:enable function_body_length
}
