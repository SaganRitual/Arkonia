import SpriteKit

class GridDebugView {
    var allTheSprites: UnsafeMutableBufferPointer<Unmanaged<GridDebugSprite>?>

    init(_ cCells: Int) {
        guard Arkonia.debugGrid else { allTheSprites = .allocate(capacity: 1); return }

        allTheSprites = .allocate(capacity: cCells)
        allTheSprites.initialize(repeating: nil)
    }

    func setState(_ newState: GridDebugSprite.State, at cellAbsoluteIndex: Int) {
        guard Arkonia.debugGrid else { return }
        allTheSprites[cellAbsoluteIndex]!.takeUnretainedValue().setState(newState)
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

                let start = Grid.shared.bareCellAt(AKPoint(x: x1, y: y1)).scenePosition
                let end =   Grid.shared.bareCellAt(AKPoint(x: x2, y: y2)).scenePosition

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

        for cellAbsoluteIndex in 0..<Grid.shared.core.theGrid.count {
            let c = Grid.shared.bareCellAt(cellAbsoluteIndex)
            let p = c.scenePosition
            let s = SKSpriteNode(texture: texture)
            s.position = p
            s.setScale(0.2)
            s.color = .darkGray
            s.colorBlendFactor = 1
            ArkoniaScene.arkonsPortal.addChild(s)

            allTheSprites[cellAbsoluteIndex] = Unmanaged.passRetained(GridDebugSprite(s))
        }
    }
}
