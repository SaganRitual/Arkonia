import CoreGraphics

extension GridCell {
    static let funkyCells = false

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

        var c = 0
        repeat {
            if c > 1000 {
                Log.L.write("Hung in getRandomEmptyCell()")
                for column in -27..<28 {
                    for row in -26..<27 {
                        let gridCell = GridCell.at(column, row)
                        Log.L.write("cell: \(gridCell.gridPosition) contains \(gridCell.contents) locked = \(gridCell.isLocked)")
                    }
                }

                preconditionFailure()
             }

            c += 1
            rg = getRandomCell()
        } while rg.contents.isOccupied()

        return rg
    }

    static func lockBirthPosition(parent: Stepper, setOwner: String) -> GridCell {
        var randomGridCell: GridCell?
        var gridPointIndex = 0

        repeat {
            gridPointIndex += 1

            let p = parent.gridCell.getGridPointByIndex(gridPointIndex)
            randomGridCell = GridCell.atIf(p)?.lock(require: false)

        } while randomGridCell?.contents != .nothing

        return randomGridCell!
    }

    static var cLrec = 0
    static func lockRandomEmptyCell(setOwner: String) -> GridCell {
        var randomGridCell: GridCell?

        var c = 0
        repeat {
            precondition(c < 1000)
            c += 1
            randomGridCell = GridCell.getRandomEmptyCell().lock(require: false)
        } while randomGridCell == nil

        return randomGridCell!
    }
}
