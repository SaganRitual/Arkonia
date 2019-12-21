import CoreGraphics

extension GridCell {
    static let funkyCells = true

    static func getRandomCell() -> GridCell {
        let wGrid = Grid.dimensions.wGrid
        let hGrid = Grid.dimensions.hGrid

        let wp = wGrid - 5, hp = hGrid - 5
        let ak = AKPoint.random(-wp..<wp, -hp..<hp)

        let gridCell = GridCell.at(ak.x, ak.y)

        if funkyCells == false { return gridCell }

        let wScene = CGFloat(Grid.dimensions.wSprite / 2)
        let hScene = CGFloat(Grid.dimensions.hSprite / 2)

        let lScene = gridCell.scenePosition.x - wScene
        let rScene = gridCell.scenePosition.x + wScene
        let bScene = gridCell.scenePosition.y - hScene
        let tScene = gridCell.scenePosition.y + hScene

        gridCell.randomScenePosition = CGPoint.random(
            xRange: lScene..<rScene, yRange: bScene..<tScene
        )

        return gridCell
    }

    static func getRandomEmptyCell() -> GridCell {
        var rg: GridCell!

        repeat {
            rg = getRandomCell()
        } while rg.contents.isOccupied()

        return rg
    }

    static func lockBirthPosition(parent: Stepper, name: String) -> HotKey {
        var randomGridCell: HotKey?
        var gridPointIndex = 0

        repeat {
            gridPointIndex += 1

            let p = parent.gridCell.getGridPointByIndex(gridPointIndex)
            var ck: GridCellKey?
            GridCell.atIf(p)?.lock(require: false, ownerName: parent.name) { ck = $0 }

            guard let hk = ck as? HotKey else { continue }

            hk.ownerName = name
            randomGridCell = hk
        } while (randomGridCell?.contents ?? .invalid) != .nothing

        Log.L.write("lockBirthPosition at \(randomGridCell!.gridPosition)", level: 54)
        return randomGridCell!
    }

    static func lockRandomEmptyCell(ownerName: String, onComplete: @escaping ((HotKey?) -> Void)) {
        Grid.shared.serialQueue.async {
            let hotKey = lockRandomEmptyCell(ownerName: ownerName)
            onComplete(hotKey)
        }
    }

    static func lockRandomEmptyCell(ownerName: String) -> HotKey? {
        var randomGridCell: HotKey?

        repeat {
            let r = GridCell.getRandomEmptyCell()
            var ck: GridCellKey?
            r.lock(require: false, ownerName: ownerName) { ck = $0 }

            guard let hk = ck as? HotKey else { continue }

            randomGridCell = hk
        } while randomGridCell == nil

        Log.L.write("lockRandomEmptyCell at \(randomGridCell!.gridPosition)", level: 54)
        return randomGridCell!
    }
}
