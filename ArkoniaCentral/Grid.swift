import SpriteKit

class Grid {
    static var shared: Grid!

    static var cells = [AKPoint: GridCell]()
    static var dimensions: Dimensions!

    let concurrentQueue = DispatchQueue(
        label: "arkonia.grid.concurrent",
        attributes: DispatchQueue.Attributes.concurrent,
        target: DispatchQueue.global(qos: .userInitiated)
    )

    init() {
        Grid.dimensions = Dimensions.setDimensions(GriddleScene.arkonsPortal!)

        Log.L.write("Grid dimensions = \(Grid.dimensions!)")
        setupGrid(GriddleScene.arkonsPortal!, drawLines: false)

        for ss in 0..<(Grid.dimensions.wGrid * 2) {
            if GridCell.atIf(AKPoint(x: ss, y: 0)) == nil { Log.L.write("+wg \(ss)"); break }
        }

        for ss in 0..<(Grid.dimensions.hGrid * 2) {
            if GridCell.atIf(AKPoint(x: 0, y: ss)) == nil { Log.L.write("+hg \(ss)"); break }
        }

        for ss in 0..<(Grid.dimensions.wGrid * 2) {
            if GridCell.atIf(AKPoint(x: -ss, y: 0)) == nil { Log.L.write("-wg \(-ss)"); break }
        }

        for ss in 0..<(Grid.dimensions.wGrid * 2) {
            if GridCell.atIf(AKPoint(x: 0, y: -ss)) == nil { Log.L.write("-hg \(-ss)"); break }
        }
    }

    func drawGridLine(_ portal: SKSpriteNode, _ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int) {
        let line = SpriteFactory.drawLine(
            from: CGPoint(x: x1, y: y1),
            to: CGPoint(x: x2, y: y2),
            color: .gray
        )

        portal.addChild(line)
    }
}
