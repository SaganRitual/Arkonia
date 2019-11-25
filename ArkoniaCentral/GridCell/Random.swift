import CoreGraphics

extension GridCell {
    static func getRandomCell() -> GridCell {
        let wGrid = Grid.dimensions.wGrid
        let hGrid = Grid.dimensions.hGrid

        let ak = AKPoint.random((-wGrid + 1)..<wGrid, (-hGrid + 1)..<hGrid)

        let gridCell = GridCell.at(ak.x, ak.y)
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

    static func lockBirthPosition(parent: Stepper, setOwner: String) -> GridCell {
        var rg: GridCell!
        var locked = false
        var gridPointIndex = 0

        repeat {
            gridPointIndex += 1

            let p = parent.gridCell.getGridPointByIndex(gridPointIndex)

            rg = GridCell.atIf(p)
            if rg == nil { continue }

            locked = SafeCell.lockGridCellIf(setOwner, at: rg.gridPosition)
        } while rg == nil || rg!.contents != .nothing || locked == false

        return rg
    }

    static func lockRandomEmptyCell(setOwner: String) -> GridCell {
        var rg: GridCell!
        var locked = false

        repeat {
            rg = GridCell.getRandomEmptyCell()
            locked = SafeCell.lockGridCellIf(setOwner, at: rg.gridPosition)
        } while locked == false

        return rg
    }
}
