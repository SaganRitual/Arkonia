import CoreGraphics

extension GridCell {
    static let funkyCells = true

    static func getRandomCell() -> GridCell {
        let wGrid = Grid.dimensions.wGrid
        let hGrid = Grid.dimensions.hGrid

        let ak = AKPoint.random((-wGrid + 1)..<wGrid, (-hGrid + 1)..<hGrid)

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

    static func lockBirthPosition(parent: Stepper) -> HotKey {
        var randomGridCell: HotKey?
        var gridPointIndex = 0

        repeat {
            gridPointIndex += 1

            let p = parent.gridCell.getGridPointByIndex(gridPointIndex)
            guard let c = GridCell.atIf(p)?.lock(require: false) as? HotKey else { continue }
            randomGridCell = c
        } while (randomGridCell?.contents ?? .invalid) != .nothing

        return randomGridCell!
    }

    static func lockRandomEmptyCell() -> HotKey? {
        var randomGridCell: HotKey?

        repeat {
            guard let c = GridCell.getRandomEmptyCell().lock(require: false) as? HotKey else { continue }
            randomGridCell = c
        } while randomGridCell == nil

        return randomGridCell!
    }
}
