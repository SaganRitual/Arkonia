import SpriteKit

class Grid {
    static var shared: Grid!
    static var dimensions: Dimensions!
    static var gridlets = [AKPoint: Gridlet]()

    let concurrentQueue = DispatchQueue(
        label: "arkonia.grid.concurrent",
        attributes: DispatchQueue.Attributes.concurrent,
        target: DispatchQueue.global(qos: .userInitiated)
    )

    let serialQueue = DispatchQueue(
        label: "arkonia.grid.serial",
        attributes: DispatchQueue.Attributes(),
        target: DispatchQueue.global(qos: .userInitiated)
    )

    init() {
        Grid.dimensions = Dimensions.setDimensions(GriddleScene.arkonsPortal!)
        setupGrid(GriddleScene.arkonsPortal!, drawLines: false)
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
