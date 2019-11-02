import SpriteKit

class Grid {
    static var shared: Grid!
    static var dimensions: Dimensions!
    static var gridlets = [AKPoint: Gridlet]()

    let gridlockQueue = DispatchQueue(
        label: "arkonia.grid.lock", qos: .userInitiated,
        attributes: DispatchQueue.Attributes.concurrent
    )

    let requestQueue = DispatchQueue(
        label: "arkonia.grid.request", qos: .userInitiated,
        attributes: DispatchQueue.Attributes.concurrent
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

extension Grid {
    func startLockCycle() { restartLockCycle() }

    func lockCyle() {

        restartLockCycle()
    }

    func restartLockCycle() {
        gridlockQueue.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.gridlockQueue.async(flags: .barrier, execute: self.lockCyle)
        }
    }
}
