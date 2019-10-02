import SpriteKit

struct AKPoint: Hashable {
    let x: Int; let y: Int

    static let zero = AKPoint(x: 0, y: 0)

    static func random(_ xRange: Range<Int>, _ yRange: Range<Int>) -> AKPoint {
        let xx = Int.random(in: xRange), yy = Int.random(in: yRange)
        return AKPoint(x: xx, y: yy)
    }

    static func + (_ lhs: AKPoint, _ rhs: AKPoint) -> AKPoint {
        return AKPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func * (_ lhs: AKPoint, _ rhs: Int) -> AKPoint {
        return AKPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}

class Gridlet {
    var contents = Contents.nothing
    let gridPosition: AKPoint
    var isEngaged = false
    let scenePosition: CGPoint
    var sprite: SKSpriteNode?

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
//        print("q", gridPosition)
        self.scenePosition = scenePosition
        self.gridPosition = gridPosition
    }

    static func at(_ x: Int, _ y: Int) -> Gridlet {
        let p = AKPoint(x: x, y: y)
        guard let g = Griddle.gridlets[p] else {
            print(Griddle.gridlets)
            fatalError()
        }
//        print("p", p, g.gridPosition)

        return g
    }

    static func at(_ position: AKPoint) -> Gridlet { return Gridlet.at(position.x, position.y) }

    static func constrainToGrid(_ x: Int, _ y: Int) -> (Int, Int) {
        let cx = Griddle.dimensions.wGrid - 1
        let cy = Griddle.dimensions.hGrid - 1

        let constrainedX = min(cx - 1, max(-cx + 1, x))
        let constrainedY = min(cy - 1, max(-cy + 1, y))

//        print("cg", x, constrainedX, y, constrainedY)

        return (constrainedX, constrainedY)
    }

    static func isOnGrid(_ x: Int, _ y: Int) -> Bool {
        let (cx, cy) = constrainToGrid(x, y)
        return cx == x && cy == y
    }

}

extension Gridlet {

    enum Contents: Double {
        case arkon, manna, nothing
    }

}

struct Dimensions {
    static let fudgFactor = CGFloat(2)

    let hGrid: Int
    let hPortal: Int
    let hSprite: Int
    let wGrid: Int
    let wPortal: Int
    let wSprite: Int

    init(_ hGrid: Int, _ hPortal: Int, _ hSprite: Int, _ wGrid: Int, _ wPortal: Int, _ wSprite: Int) {
        self.hGrid = hGrid
        self.hPortal = hPortal
        self.hSprite = hSprite
        self.wGrid = wGrid
        self.wPortal = wPortal
        self.wSprite = wSprite
    }
}

class Griddle {
    static var dimensions: Dimensions!
    static var gridlets = [AKPoint: Gridlet]()

    init(_ portal: SKSpriteNode, _ spriteFactory: SpriteFactory) {
        Griddle.dimensions = Griddle.setDimensions(portal)
        setupGrid(portal, drawLines: false)
    }

    func drawGridLine(_ portal: SKSpriteNode, _ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
        let line = SpriteFactory.drawLine(
            from: CGPoint(x: x1, y: y1),
            to: CGPoint(x: x2, y: y2),
            color: .gray
        )

        portal.addChild(line)
    }

    func setupGrid(_ portal: SKSpriteNode, drawLines: Bool = false) {
        let d = Griddle.dimensions!

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
        let d = Griddle.dimensions!

        for x in stride(from: 0, to: d.wPortal - d.wSprite, by: d.wSprite) {
            let xGrid = x / d.wSprite

            switch (x, y) {
            case (0, 0):
                let p = AKPoint(x: xGrid, y: yGrid)
//                print("place1 at", p)
                Griddle.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint.zero)

            case (_, 0):

                let p = AKPoint(x:  xGrid, y: yGrid)
//                print("place2 at", p)
                Griddle.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint(x:  x, y: y))

                if xGrid < d.wGrid {
                    let q = AKPoint(x: -xGrid, y: yGrid)
//                    print("place3 at", q)
                    Griddle.gridlets[q] = Gridlet(gridPosition: q, scenePosition: CGPoint(x: -x, y: y))
                } else {
//                    print("?3", xGrid, d.wGrid)
                }

            case (0, _):
                let p = AKPoint(x: xGrid, y:  yGrid)
//                print("place at4", p)
                Griddle.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint(x: x, y:  y))

                if yGrid < d.hGrid {
                    let q = AKPoint(x: xGrid, y: -yGrid)
//                    print("place at5", q)
                    Griddle.gridlets[q] = Gridlet(gridPosition: q, scenePosition: CGPoint(x: x, y: -y))
                } else {
//                    print("?5", yGrid, d.hGrid)
                }

            default:
                let p = AKPoint(x:  xGrid, y:  yGrid)
                Griddle.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint(x:  x, y:  y))
//                print("placeX at", p)

                if xGrid < d.wGrid && yGrid < d.hGrid {
                    let s = AKPoint(x: -xGrid, y: -yGrid)

                    Griddle.gridlets[s] = Gridlet(gridPosition: s, scenePosition: CGPoint(x: -x, y: -y))
//                    print("place6 at", s)
                } else {
//                    print("6?", xGrid, d.wGrid, yGrid, d.hGrid)
                }

                if xGrid < d.wGrid {
                    let q = AKPoint(x: -xGrid, y:  yGrid)
                    Griddle.gridlets[q] = Gridlet(gridPosition: q, scenePosition: CGPoint(x: -x, y:  y))
//                    print("place7 at", q)
                } else {
//                    print("7?", xGrid, d.wGrid, yGrid, d.hGrid)
                }

                if yGrid < d.hGrid {
                    let r = AKPoint(x:  xGrid, y: -yGrid)
                    Griddle.gridlets[r] = Gridlet(gridPosition: r, scenePosition: CGPoint(x:  x, y: -y))
//                    print("place8 at", r)
                } else {
//                    print("8?", xGrid, d.wGrid, yGrid, d.hGrid)
                }
            }
        }
    }
    //swiftmint:enable function_body_length

    static func setDimensions(_ portal: SKSpriteNode) -> Dimensions {
        let tAtlas = SKTextureAtlas(named: "Arkons")
        let tTexture = tAtlas.textureNamed("spark-thorax-large")

        let hSprite = Int(tTexture.size().height / Dimensions.fudgFactor)
        let wSprite = Int(tTexture.size().width / Dimensions.fudgFactor)

        let hPortal = Int((1 / Arkon.scaleFactor) * portal.size.height / Dimensions.fudgFactor) - hSprite
        let wPortal = Int((1 / Arkon.scaleFactor) * portal.size.width / Dimensions.fudgFactor) - wSprite
        let hGrid = Int(hPortal / hSprite)
        let wGrid = Int(wPortal / wSprite)

        return Dimensions(hGrid, hPortal, hSprite, wGrid, wPortal, wSprite)
    }

}
