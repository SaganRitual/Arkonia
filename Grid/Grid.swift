import SpriteKit

class Grid {
    static var shared: Grid!
    static private(set) var pixelsPerMeter = CGFloat.zero

    private var elles = [[GridCell]]()

    private let atlas: SKTextureAtlas
    private let noseTexture: SKTexture
    private let toothTexture: SKTexture
    private weak var portal: SKSpriteNode?

    let gridCellWidthInPix: Int, gridCellHeightInPix: Int
    let gridHeightInCells: Int, gridWidthInCells: Int
    let portalHeightInPix, portalWidthInPix: Int
    let hypoteneuse: CGFloat

    private(set) var xGrid = 0, yGrid = 0
    private(set) var xPortal = 0, yPortal = 0

    static let arkonsPlaneQueue = DispatchQueue(
        label: "arkon.plane.serial", target: DispatchQueue.global()
    )

    static func makeGrid(on portal: SKSpriteNode) {
        shared = Grid(on: portal)
        shared.setupGrid()
    }

    private init(on portal: SKSpriteNode) {
//        portal.color = .blue
//        portal.colorBlendFactor = 1
//        portal.alpha = 0.25

        self.portal = portal

        atlas = SKTextureAtlas(named: "Arkons")
        noseTexture = atlas.textureNamed("spark-nose-large")
        toothTexture = atlas.textureNamed("spark-tooth-large")

        let zf = CGFloat(Arkonia.zoomFactor)

        gridCellWidthInPix = Int(noseTexture.size().width / zf)
        gridCellHeightInPix = Int(noseTexture.size().height / zf)

        portalWidthInPix = Int(floor(portal.size.width * zf))
        portalHeightInPix = Int(floor(portal.size.height * zf))

        let wc = Int(floor(CGFloat(portalWidthInPix) / noseTexture.size().width))
        let hc = Int(floor(CGFloat(portalHeightInPix) / noseTexture.size().height))

        gridWidthInCells = wc - ((wc % 2) == 0 ? 1 : 0)
        gridHeightInCells = hc - ((hc % 2) == 0 ? 1 : 0)

        hypoteneuse = sqrt(CGFloat(portalWidthInPix * portalWidthInPix) + CGFloat(portalHeightInPix * portalHeightInPix))

        Grid.pixelsPerMeter = CGFloat(gridCellWidthInPix)

        Debug.log {
            "cell width \(gridCellWidthInPix * Int(zf))px, height \(gridCellHeightInPix * Int(zf))px"
            + "; portal width \(portalWidthInPix)px, height \(portalHeightInPix)px"
            + "; grid width \(2 * gridWidthInCells) cells, height \(2 * gridHeightInCells) cells"
        }
    }

    func getCellIf(at position: AKPoint) -> GridCell? {
        return isOnGrid(position) ? getCell(at: position) : nil
    }

    func getCell(at position: AKPoint) -> GridCell {
        elles[position.y + gridHeightInCells][position.x + gridWidthInCells]
    }

    func isOnGrid(_ position: AKPoint) -> Bool {
        return position.x >= -gridWidthInCells && position.x < gridWidthInCells &&
               position.y >= -gridHeightInCells && position.y < gridHeightInCells
    }
}

extension Grid {
    private func setupGrid() {
        for yG in -gridHeightInCells..<gridHeightInCells { setupRow(yG) }

        yGrid = -gridHeightInCells
        xGrid = -gridWidthInCells
    }

    private func setupRow(_ yG: Int) {
        elles.append([GridCell]())
        for xG in -gridWidthInCells..<gridWidthInCells { setupCell(xG, yG) }
    }

    private func setupCell(_ xG: Int, _ yG: Int) {
        let akp = AKPoint(x: xG, y: yG)

        xPortal = gridCellWidthInPix / 2 + xGrid * gridCellWidthInPix
        yPortal = gridCellHeightInPix / 2 + yGrid * gridCellHeightInPix

        let cgp = CGPoint(x: gridCellWidthInPix / 4 + xG * xPortal, y: gridCellHeightInPix / 4 + yG * yPortal)
        elles[yG + gridHeightInCells].append(GridCell(gridPosition: akp, scenePosition: cgp))
    }
}
