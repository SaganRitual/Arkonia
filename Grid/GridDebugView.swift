import SpriteKit

class GridDebugView {
    var allTheSprites: UnsafeMutableBufferPointer<Unmanaged<GridSpriteNode>?>

    init(_ cCells: Int) {
        allTheSprites = .allocate(capacity: cCells)
        allTheSprites.initialize(repeating: nil)
    }

    func showLock(_ absoluteIndex: Int, _ state: GridSpriteNode.State) {
        let p = Grid.absolutePosition(of: absoluteIndex)
        Debug.log(level: 204) { "show lock at \(absoluteIndex) \(p)" }

        if let sprite = allTheSprites[absoluteIndex]?.takeUnretainedValue() {
            sprite.showLock(state)
        }
    }
}

extension GridDebugView {
    enum LineSet { case horizontal, vertical }

    func drawGridLines() {
        let halfW = Grid.shared.core.gridDimensionsCells.width / 2
        let halfH = Grid.shared.core.gridDimensionsCells.height / 2

        func drawSet(_ halfD1: Int, _ halfD2: Int, _ lineSet: LineSet) {
            for i in -halfD2..<halfD2 {
                let x1: Int, y1: Int, x2: Int, y2: Int

                switch lineSet {
                case .horizontal:
                    x1 = -halfD1; y1 = i; x2 = halfD1; y2 = i
                case .vertical:
                    x1 = i; y1 = -halfD1; x2 = i; y2 = halfD1
                }

                let start = Grid.shared.cellAt(AKPoint(x: x1, y: y1)).scenePosition
                let end =   Grid.shared.cellAt(AKPoint(x: x2, y: y2)).scenePosition

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

        let halfW = Grid.shared.core.gridDimensionsCells.width / 2
        let halfH = Grid.shared.core.gridDimensionsCells.height / 2

        for y in -halfH..<halfH {
            for x in -halfW..<halfW {
                let a = AKPoint(x: x, y: y)
                let i = Grid.absoluteIndex(of: a)
                let c = Grid.shared.cellAt(i)
                let p = c.scenePosition
                let s = SKSpriteNode(texture: texture)
                s.position = p
                s.setScale(0.2)
                s.color = .darkGray
                s.colorBlendFactor = 1
                ArkoniaScene.arkonsPortal.addChild(s)

                allTheSprites[i] = Unmanaged.passRetained(AKSpriteNode(s))
            }
        }
    }
}
