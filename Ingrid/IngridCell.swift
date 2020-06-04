import Foundation

class IngridCellDescriptor {
    let absoluteIndex: Int
    let cell: IngridCell?
    let requiresTeleportation: Bool

    init() {
        absoluteIndex = 0
        cell = nil
        requiresTeleportation = false
    }

    init(_ cell: IngridCell?, _ absoluteIndex: Int, _ requiresTeleportation: Bool = false) {
        // cell == nil means we coulnd't lock the cell, which means that although
        // we know it's there, we can't see inside it, and we can't jump to it
        self.cell = cell

        self.absoluteIndex = absoluteIndex
        self.requiresTeleportation = requiresTeleportation
    }
}

class IngridCell {
    let absoluteIndex: Int
    let gridPosition: AKPoint
    var isLocked = false
    let randomScenePosition: CGPoint?
    let scenePosition: CGPoint
    let waitingLockRequests: Cbuffer<EngagerSpec>

    init() {
        absoluteIndex = 0; gridPosition = .zero; randomScenePosition = nil;
        scenePosition = .zero; waitingLockRequests = .init(cElements: 0)
    }

    init(
        _ absoluteIndex: Int, _ absolutePosition: AKPoint,
        _ cellSideInPix: CGFloat, _ funkyCellsMultiplier: CGFloat?
    ) {
        self.absoluteIndex = absoluteIndex
        self.gridPosition = absolutePosition

        self.scenePosition = self.gridPosition.asPoint() * cellSideInPix / 2
        self.waitingLockRequests = .init(cElements: 10, mode: .fifo)

        guard let fm = funkyCellsMultiplier else
            { self.randomScenePosition = nil; return }

        // Set a random position on the display for this cell, slightly
        // offset from the center of the cell, just so Arkonia won't look
        // like a boring old rectilinear grid
        let wScene = cellSideInPix / 2
        let hScene = cellSideInPix / 2

        let lScene = scenePosition.x - wScene * fm
        let rScene = scenePosition.x + wScene * fm
        let bScene = scenePosition.y - hScene * fm
        let tScene = scenePosition.y + hScene * fm

        self.randomScenePosition = CGPoint.random(
            xRange: lScene..<rScene, yRange: bScene..<tScene
        )
    }
}
