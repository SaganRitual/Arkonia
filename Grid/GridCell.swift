import Foundation

class GridCell {
    let absoluteIndex: Int
    let gridPosition: AKPoint
    let scenePosition: CGPoint

    init() {
        absoluteIndex = 0; gridPosition = .zero; scenePosition = .zero
    }

    init(
        _ absoluteIndex: Int, _ absolutePosition: AKPoint, _ paddingPixels: CGSize,
        _ cellSideInPix: CGFloat, _ funkyCellsMultiplier: CGFloat?
    ) {
        self.absoluteIndex = absoluteIndex
        self.gridPosition = absolutePosition

        // Don't ask me where these numbers come from. I'm doing some much scaling
        // up and down I don't even want to look at it
        let fudge = CGPoint(x: -0.5, y: +0.25)
        let sp = ((self.gridPosition.asPoint() + fudge) * cellSideInPix) + paddingPixels.asPoint()

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
