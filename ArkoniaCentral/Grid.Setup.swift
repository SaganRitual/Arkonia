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
                Grid.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint.zero)

            case (_, 0):

                let p = AKPoint(x:  xGrid, y: yGrid)
                Grid.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint(x:  x, y: y))

                if xGrid < d.wGrid {
                    let q = AKPoint(x: -xGrid, y: yGrid)
                    Grid.gridlets[q] = Gridlet(gridPosition: q, scenePosition: CGPoint(x: -x, y: y))
                }

            case (0, _):
                let p = AKPoint(x: xGrid, y:  yGrid)
                Grid.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint(x: x, y:  y))

                if yGrid < d.hGrid {
                    let q = AKPoint(x: xGrid, y: -yGrid)
                    Grid.gridlets[q] = Gridlet(gridPosition: q, scenePosition: CGPoint(x: x, y: -y))
                }

            default:
                let p = AKPoint(x:  xGrid, y:  yGrid)
                Grid.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint(x:  x, y:  y))

                if xGrid < d.wGrid && yGrid < d.hGrid {
                    let s = AKPoint(x: -xGrid, y: -yGrid)

                    Grid.gridlets[s] = Gridlet(gridPosition: s, scenePosition: CGPoint(x: -x, y: -y))
                }

                if xGrid < d.wGrid {
                    let q = AKPoint(x: -xGrid, y:  yGrid)
                    Grid.gridlets[q] = Gridlet(gridPosition: q, scenePosition: CGPoint(x: -x, y:  y))
                }

                if yGrid < d.hGrid {
                    let r = AKPoint(x:  xGrid, y: -yGrid)
                    Grid.gridlets[r] = Gridlet(gridPosition: r, scenePosition: CGPoint(x:  x, y: -y))
                }
            }
        }
    }
    //swiftmint:enable function_body_length
}

extension Grid {
    static let moves = [
         AKPoint(x: 0, y:   1), AKPoint(x:  1, y:  1), AKPoint(x:  1, y:  0),
         AKPoint(x: 1, y:  -1), AKPoint(x:  0, y: -1), AKPoint(x: -1, y: -1),
         AKPoint(x: -1, y:  0), AKPoint(x: -1, y:  1)
    ]

    static let gridInputs = [
        AKPoint(x: -4, y:  4), AKPoint(x: -3, y:  4), AKPoint(x: -2, y:  4), AKPoint(x: -1, y:  4), AKPoint(x:   0, y:  4), AKPoint(x:  1, y:  4), AKPoint(x:  2, y:  4), AKPoint(x:  3, y:  4), AKPoint(x:  4, y:  4),
        AKPoint(x: -4, y:  3), AKPoint(x: -3, y:  3), AKPoint(x: -2, y:  3), AKPoint(x: -1, y:  3), AKPoint(x:   0, y:  3), AKPoint(x:  1, y:  3), AKPoint(x:  2, y:  3), AKPoint(x:  3, y:  3), AKPoint(x:  4, y:  3),
        AKPoint(x: -4, y:  2), AKPoint(x: -3, y:  2), AKPoint(x: -2, y:  2), AKPoint(x: -1, y:  2), AKPoint(x:   0, y:  2), AKPoint(x:  1, y:  2), AKPoint(x:  2, y:  2), AKPoint(x:  3, y:  2), AKPoint(x:  4, y:  2),
        AKPoint(x: -4, y:  1), AKPoint(x: -3, y:  1), AKPoint(x: -2, y:  1), AKPoint(x: -1, y:  1), AKPoint(x:   0, y:  1), AKPoint(x:  1, y:  1), AKPoint(x:  2, y:  1), AKPoint(x:  3, y:  1), AKPoint(x:  4, y:  1),
        AKPoint(x: -4, y:  0), AKPoint(x: -3, y:  0), AKPoint(x: -2, y:  0), AKPoint(x: -1, y:  0), AKPoint(x:   0, y:  0), AKPoint(x:  1, y:  0), AKPoint(x:  2, y:  0), AKPoint(x:  3, y:  0), AKPoint(x:  4, y:  0),
        AKPoint(x: -4, y: -1), AKPoint(x: -3, y: -1), AKPoint(x: -2, y: -1), AKPoint(x: -1, y: -1), AKPoint(x:   0, y: -1), AKPoint(x:  1, y: -1), AKPoint(x:  2, y: -1), AKPoint(x:  3, y: -1), AKPoint(x:  4, y: -1),
        AKPoint(x: -4, y: -2), AKPoint(x: -3, y: -2), AKPoint(x: -2, y: -2), AKPoint(x: -1, y: -2), AKPoint(x:   0, y: -2), AKPoint(x:  1, y: -2), AKPoint(x:  2, y: -2), AKPoint(x:  3, y: -2), AKPoint(x:  4, y: -2),
        AKPoint(x: -4, y: -3), AKPoint(x: -3, y: -3), AKPoint(x: -2, y: -3), AKPoint(x: -1, y: -3), AKPoint(x:   0, y: -3), AKPoint(x:  1, y: -3), AKPoint(x:  2, y: -3), AKPoint(x:  3, y: -3), AKPoint(x:  4, y: -3),
        AKPoint(x: -4, y: -4), AKPoint(x: -3, y: -4), AKPoint(x: -2, y: -4), AKPoint(x: -1, y: -4), AKPoint(x:   0, y: -4), AKPoint(x:  1, y: -4), AKPoint(x:  2, y: -4), AKPoint(x:  3, y: -4), AKPoint(x:  4, y: -4)
    ]
}
