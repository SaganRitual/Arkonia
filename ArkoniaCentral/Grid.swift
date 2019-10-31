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

class Grid {
    static var shared: Grid!
    static var dimensions: Dimensions!
    static var gridlets = [AKPoint: Gridlet]()

    init() {
        Grid.dimensions = Grid.setDimensions(GriddleScene.arkonsPortal!)
        setupGrid(GriddleScene.arkonsPortal!, drawLines: false)
    }

    func drawGridLine(_ portal: SKSpriteNode, _ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
        let line = SpriteFactory.drawLine(
            from: CGPoint(x: x1, y: y1),
            to: CGPoint(x: x2, y: y2),
            color: .gray
        )

//        print("C", line.name!)
        portal.addChild(line)
//        print("D")
    }

    static let lockQueue = DispatchQueue(
        label: "arkonia.lock.grid", qos: .default,
        attributes: DispatchQueue.Attributes.concurrent
    )

    static func lock<T>(
        _ execute: Sync.Lockable<T>.LockExecute? = nil,
        _ userOnComplete: Sync.Lockable<T>.LockOnComplete? = nil,
        _ completionMode: Sync.CompletionMode = .concurrent
    ) {
        func debugEx() -> [T]? { print("Grid.barrier"); return execute?() }
        func debugOc(_ args: [T]?) { print("Grid.concurrent"); userOnComplete?(args) }
        Sync.Lockable<T>(Grid.lockQueue).lock(
            execute, userOnComplete, completionMode
        )
    }

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
//                print("place1 at", p)
                Grid.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint.zero)

            case (_, 0):

                let p = AKPoint(x:  xGrid, y: yGrid)
//                print("place2 at", p)
                Grid.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint(x:  x, y: y))

                if xGrid < d.wGrid {
                    let q = AKPoint(x: -xGrid, y: yGrid)
//                    print("place3 at", q)
                    Grid.gridlets[q] = Gridlet(gridPosition: q, scenePosition: CGPoint(x: -x, y: y))
                } else {
//                    print("?3", xGrid, d.wGrid)
                }

            case (0, _):
                let p = AKPoint(x: xGrid, y:  yGrid)
//                print("place at4", p)
                Grid.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint(x: x, y:  y))

                if yGrid < d.hGrid {
                    let q = AKPoint(x: xGrid, y: -yGrid)
//                    print("place at5", q)
                    Grid.gridlets[q] = Gridlet(gridPosition: q, scenePosition: CGPoint(x: x, y: -y))
                } else {
//                    print("?5", yGrid, d.hGrid)
                }

            default:
                let p = AKPoint(x:  xGrid, y:  yGrid)
                Grid.gridlets[p] = Gridlet(gridPosition: p, scenePosition: CGPoint(x:  x, y:  y))
//                print("placeX at", p)

                if xGrid < d.wGrid && yGrid < d.hGrid {
                    let s = AKPoint(x: -xGrid, y: -yGrid)

                    Grid.gridlets[s] = Gridlet(gridPosition: s, scenePosition: CGPoint(x: -x, y: -y))
//                    print("place6 at", s)
                } else {
//                    print("6?", xGrid, d.wGrid, yGrid, d.hGrid)
                }

                if xGrid < d.wGrid {
                    let q = AKPoint(x: -xGrid, y:  yGrid)
                    Grid.gridlets[q] = Gridlet(gridPosition: q, scenePosition: CGPoint(x: -x, y:  y))
//                    print("place7 at", q)
                } else {
//                    print("7?", xGrid, d.wGrid, yGrid, d.hGrid)
                }

                if yGrid < d.hGrid {
                    let r = AKPoint(x:  xGrid, y: -yGrid)
                    Grid.gridlets[r] = Gridlet(gridPosition: r, scenePosition: CGPoint(x:  x, y: -y))
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

        let hPortal = Int((1 / Wangkhi.scaleFactor) * portal.size.height / Dimensions.fudgFactor) - hSprite
        let wPortal = Int((1 / Wangkhi.scaleFactor) * portal.size.width / Dimensions.fudgFactor) - wSprite
        let hGrid = Int(hPortal / hSprite)
        let wGrid = Int(wPortal / wSprite)

        return Dimensions(hGrid, hPortal, hSprite, wGrid, wPortal, wSprite)
    }

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
