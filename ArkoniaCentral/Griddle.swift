import SpriteKit

struct AKPoint {
    let x: Int; let y: Int

    static func random(_ xRange: Range<Int>, _ yRange: Range<Int>) -> AKPoint {
        let xx = Int.random(in: xRange), yy = Int.random(in: yRange)
        return AKPoint(x: xx, y: yy)
    }
}

class Gridlet {
    var contents = Contents.nothing
    let gridPosition: AKPoint
    let scenePosition: CGPoint

    init(gridPosition: AKPoint, scenePosition: CGPoint) {
        self.scenePosition = scenePosition
        self.gridPosition = gridPosition
    }

    static func at(_ x: Int, _ y: Int) -> Gridlet {
        var (constrainedX, constrainedY) = constrainToGrid(x, y)

        constrainedX += Griddle.dimensions.wGrid
        constrainedY  = -constrainedY + Griddle.dimensions.hGrid

        let g = Griddle.gridlets[constrainedY][constrainedX]
//        print(
//            "at", x, y,
//            constrainedX, constrainedY,
//            g.gridPosition.x, g.gridPosition.y,
//            g.scenePosition.x, g.scenePosition.y
//        )
        return g
    }

    static func at(_ position: AKPoint) -> Gridlet { return Gridlet.at(position.x, position.y) }

    static func constrainToGrid(_ x: Int, _ y: Int) -> (Int, Int) {
        var constrainedX = max(-Griddle.dimensions.wGrid, x)
        constrainedX = min(Griddle.dimensions.wGrid, constrainedX)

        var constrainedY = max(-Griddle.dimensions.hGrid, y)
        constrainedY = min(Griddle.dimensions.hGrid, constrainedY)

//        print("cg", x, constrainedX, y, constrainedY)

        return (constrainedX, constrainedY)
    }

}

extension Gridlet {

    enum Contents {
        case arkon, manna, nothing
    }

}

struct Dimensions {
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
    static var gridlets = [[Gridlet]]()

    init(_ portal: SKSpriteNode, _ spriteFactory: SpriteFactory) {
        Griddle.dimensions = Griddle.setDimensions(portal)
        drawGridLines(portal)
        setupGrid(portal)
    }

    func drawGridLine(_ portal: SKSpriteNode, _ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
        let line = SpriteFactory.drawLine(
            from: CGPoint(x: x1, y: y1),
            to: CGPoint(x: x2, y: y2),
            color: .gray
        )

        portal.addChild(line)
    }

    func drawGridLines(_ portal: SKSpriteNode) {
        let d = Griddle.dimensions!

        for x in stride(from: 0, to: d.wPortal, by: d.wSprite) {
            drawGridLine(portal, -x, -d.hPortal, -x, d.hPortal)
            drawGridLine(portal, +x, -d.hPortal, +x, d.hPortal)
        }

        for y in stride(from: 0, to: d.wPortal, by: d.wSprite) {
            drawGridLine(portal, -d.wPortal, -y, d.wPortal, -y)
            drawGridLine(portal, -d.wPortal, +y, d.wPortal, +y)
        }

//        print("w", d.wPortal * 2 / d.wSprite, d.hPortal * 2 / d.hSprite)

        let shape = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 100))
        portal.addChild(shape)
    }

    static func setDimensions(_ portal: SKSpriteNode) -> Dimensions {
        let tAtlas = SKTextureAtlas(named: "Arkons")
        let tTexture = tAtlas.textureNamed("spark-thorax-large")

        let hSprite = Int(tTexture.size().height)// / 2
        let wSprite = Int(tTexture.size().width)// / 2

        let hPortal = Int((1 / Arkon.scaleFactor) * portal.size.height / 2) - hSprite
        let wPortal = Int((1 / Arkon.scaleFactor) * portal.size.width / 2) - wSprite
        let hGrid = Int(hPortal / hSprite)
        let wGrid = Int(wPortal / wSprite)

        return Dimensions(hGrid, hPortal, hSprite, wGrid, wPortal, wSprite)
    }

    func setupGrid(_ portal: SKSpriteNode) {
        let d = Griddle.dimensions!
        let hGrid = d.hGrid
        let wGrid = d.wGrid
        let hPortal = d.hPortal
        let wPortal = d.wPortal
        let hSprite = d.hSprite
        let wSprite = d.wSprite

        Griddle.gridlets.reserveCapacity(d.hGrid)

        var yGrid = -hGrid

        for yScene in stride(from: -hPortal, to: hPortal, by: hSprite) {

            var gridRow = [Gridlet]()
            gridRow.reserveCapacity(d.wGrid)

            var xGrid = -wGrid

            for xScene in stride(from: -wPortal, to: wPortal, by: wSprite) {

                let gridlet = Gridlet(
                    gridPosition: AKPoint(x: xGrid, y: -yGrid),
                    scenePosition: CGPoint(x: xScene, y: -yScene)
                )

                gridRow.append(gridlet)

                xGrid += 1

//                print("xy", xGrid, "=", xScene, -yGrid, "=", -yScene)
            }

            Griddle.gridlets.append(gridRow)

            yGrid += 1
        }
    }

}
