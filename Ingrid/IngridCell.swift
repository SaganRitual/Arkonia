import Foundation

struct IngridCellDescriptor {
    let absoluteIndex: Int
    let cell: IngridCell?
    let virtualScenePosition: CGPoint?  // For asteroids-style wraparound movement

    init() {
        absoluteIndex = 0
        cell = nil
        virtualScenePosition = nil
    }

    init(_ cell: IngridCell?, _ absoluteIndex: Int, _ virtualScenePosition: CGPoint?) {
        // cell == nil means we coulnd't lock the cell, which means that although
        // we know it's there, we can't see inside it, and we can't jump to it
        self.cell = cell

        self.absoluteIndex = absoluteIndex
        self.virtualScenePosition = virtualScenePosition
    }

    init(_ cell: IngridCell, _ virtualScenePosition: CGPoint? = nil) {
        self.cell = cell
        self.absoluteIndex = cell.absoluteIndex
        self.virtualScenePosition = virtualScenePosition
    }
}

class IngridCell {
    let absoluteIndex: Int
    let gridPosition: AKPoint
    let scenePosition: CGPoint

    init() {
        absoluteIndex = 0; gridPosition = .zero; scenePosition = .zero
    }

    init(
        _ absoluteIndex: Int, _ absolutePosition: AKPoint,
        _ cellSideInPix: CGFloat, _ funkyCellsMultiplier: CGFloat?
    ) {
        self.absoluteIndex = absoluteIndex
        self.gridPosition = absolutePosition

        let sp = self.gridPosition.asPoint() * cellSideInPix

        guard let fm = funkyCellsMultiplier else {
            self.scenePosition = sp; return
        }

        // Set a random position on the display for this cell, slightly
        // offset from the center of the cell, just so Arkonia won't look
        // like a boring old rectilinear grid
        let wScene = cellSideInPix / 2
        let hScene = cellSideInPix / 2

        let lScene = sp.x - wScene * fm
        let rScene = sp.x + wScene * fm
        let bScene = sp.y - hScene * fm
        let tScene = sp.y + hScene * fm

        self.scenePosition = CGPoint.random(
            xRange: lScene..<rScene, yRange: bScene..<tScene
        )
    }
}
