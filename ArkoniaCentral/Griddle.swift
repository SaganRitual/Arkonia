import SpriteKit

struct AKPoint: Hashable {
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
//        print("q", gridPosition)
        self.scenePosition = scenePosition
        self.gridPosition = gridPosition
    }

    static func at(_ x: Int, _ y: Int) -> Gridlet {
        let p = AKPoint(x: x, y: y)
//        print("p", p)
        let g = Griddle.gridlets[p]!

        return g
    }

    static func at(_ position: AKPoint) -> Gridlet { return Gridlet.at(position.x, position.y) }

    static func constrainToGrid(_ x: Int, _ y: Int) -> (Int, Int) {
        let cx = Griddle.dimensions.wGrid - 1
        let cy = Griddle.dimensions.hGrid - 1

        let constrainedX = min(cx, max(-cx, x))
        let constrainedY = min(cy, max(-cy, y))

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

        for y in stride(from: 0, to: d.hPortal, by: d.hSprite) {
            let yGrid = y / d.hSprite

            if drawLines == true {
                if y != 0 { drawGridLine(portal, -d.wPortal, -y, d.wPortal, -y) }

                drawGridLine(portal, -d.wPortal, +y, d.wPortal, +y)
            }

            placeGridlet(y, yGrid)
        }

//        print("w", d.wPortal * 2 / d.wSprite, d.hPortal * 2 / d.hSprite)

        let shape = SKSpriteNode(color: .blue, size: CGSize(width: 100, height: 100))
        portal.addChild(shape)
    }

    func placeGridlet(_ y: Int, _ yGrid: Int) {
        let d = Griddle.dimensions!

        for x in stride(from: 0, to: d.wPortal, by: d.wSprite) {
            let xGrid = x / d.wSprite

            switch (x, y) {
            case (0, 0):
                let p = AKPoint(x: xGrid, y: yGrid)
                Griddle.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint.zero)

            case (_, 0):
                let p = AKPoint(x:  xGrid, y: yGrid)
                let q = AKPoint(x: -xGrid, y: yGrid)

                Griddle.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint(x:  x, y: y))
                Griddle.gridlets[q] = Gridlet(gridPosition: q, scenePosition: CGPoint(x: -x, y: y))

            case (0, _):
                let p = AKPoint(x: xGrid, y:  yGrid)
                let q = AKPoint(x: xGrid, y: -yGrid)

                Griddle.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint(x: x, y:  y))
                Griddle.gridlets[q] = Gridlet(gridPosition: q, scenePosition: CGPoint(x: x, y: -y))

            default:
                let p = AKPoint(x:  xGrid, y:  yGrid)
                let q = AKPoint(x: -xGrid, y:  yGrid)
                let r = AKPoint(x:  xGrid, y: -yGrid)
                let s = AKPoint(x: -xGrid, y: -yGrid)

                Griddle.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint(x:  x, y:  y))
                Griddle.gridlets[q] = Gridlet(gridPosition: q, scenePosition: CGPoint(x: -x, y:  y))
                Griddle.gridlets[r] = Gridlet(gridPosition: r, scenePosition: CGPoint(x:  x, y: -y))
                Griddle.gridlets[s] = Gridlet(gridPosition: s, scenePosition: CGPoint(x: -x, y: -y))
            }
        }
    }

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
