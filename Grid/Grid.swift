import SpriteKit

class Grid {
    static var shared: Grid!

    private var elles = [[GridCell]]()

    private let atlas: SKTextureAtlas
    private let noseTexture: SKTexture
    private weak var portal: SKSpriteNode?

    private var cellIndex = 0
    let cPortal, rPortal: Int
    private(set) var hGrid = 0, wGrid = 0
    private let hPortal, wPortal: Int
    let hypoteneuse: CGFloat
    private(set) var xGrid = 0, yGrid = 0
    private var xPortal = 0, yPortal = 0

    static let arkonsPlaneQueue = DispatchQueue(
        label: "arkon.plane.serial", target: DispatchQueue.global()
    )

    init(on portal: SKSpriteNode) {
//        portal.color = .blue
//        portal.colorBlendFactor = 1
//        portal.alpha = 0.25

        self.portal = portal

        atlas = SKTextureAtlas(named: "Arkons")
        noseTexture = atlas.textureNamed("spark-nose-large")

        cPortal = Int(noseTexture.size().width / Arkonia.zoomFactor)
        rPortal = Int(noseTexture.size().height / Arkonia.zoomFactor)

        wPortal = Int(floor(portal.size.width * Arkonia.zoomFactor))
        hPortal = Int(floor(portal.size.height * Arkonia.zoomFactor))

        hypoteneuse = sqrt(CGFloat(wPortal * wPortal) + CGFloat(hPortal * hPortal))
    }

    func getCellIf(at position: AKPoint) -> GridCell? {
        return isOnGrid(position) ? getCell(at: position) : nil
    }

    func getCell(at position: AKPoint) -> GridCell {
        elles[position.y + hGrid][position.x + wGrid]
    }

    func isOnGrid(_ position: AKPoint) -> Bool {
        return position.x >= -wGrid && position.x < wGrid &&
               position.y >= -hGrid && position.y < hGrid
    }

    func postInit() {
        wGrid = Int(floor(CGFloat(wPortal) / noseTexture.size().width))
        hGrid = Int(floor(CGFloat(hPortal) / noseTexture.size().height))

        wGrid -= (wGrid % 2) == 0 ? 1 : 0
        hGrid -= (hGrid % 2) == 0 ? 1 : 0

        Debug.log {
            "pix/row \(rPortal), column \(cPortal)"
            + "; pix width \(wPortal)? height \(hPortal)?"
            + "; grid width \(wGrid * 2) height \(hGrid * 2)"
        }

        setupGrid()
    }
}

extension Grid {
    private func setupGrid() {
        for yG in -hGrid..<hGrid { setupRow(yG) }

        yGrid = -hGrid
        xGrid = -wGrid
    }

    private func setupRow(_ yG: Int) {
        elles.append([GridCell]())
        for xG in -wGrid..<wGrid { setupCell(xG, yG) }
    }

    private func setupCell(_ xG: Int, _ yG: Int) {
        let akp = AKPoint(x: xG, y: yG)

        xPortal = cPortal / 2 + xGrid * cPortal
        yPortal = rPortal / 2 + yGrid * rPortal

        let cgp = CGPoint(x: cPortal / 4 + xG * xPortal, y: rPortal / 4 + yG * yPortal)
        elles[yG + hGrid].append(GridCell(gridPosition: akp, scenePosition: cgp))
    }
}
