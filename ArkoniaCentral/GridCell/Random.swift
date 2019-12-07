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

    static var cGrec = 0
    static var highWatercGrec = 0
    static func getRandomEmptyCell() -> GridCell {
        var rg: GridCell!

        cGrec = 0
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
        } while randomGridCell?.contents != .nothing

        return randomGridCell!
    }

    static var cLrec = 0
    static var highWatercLrec = 0
    static func lockRandomEmptyCell() -> HotKey? {
        var randomGridCell: HotKey?

        cLrec = 0
        repeat {
            if cLrec > highWatercLrec {
                Log.L.write("Hung in lockRandomEmptyCell(); \(cLrec) loops", level: 31)
                highWatercLrec = cLrec
                precondition(highWatercLrec < 1000)

                var inUseCount = 0
                var lockedCount = 0
                var availableCount = 0
                for column in -27..<28 {
                    for row in -26..<27 {
                        let gridCell = GridCell.at(column, row)
                        if gridCell.isLocked { lockedCount += 1 }
                        if gridCell.contents.isOccupied() { inUseCount += 1 } else { availableCount += 1 }
                    }
                }

                Log.L.write("Hung in lockRandomEmptyCell(); \(cLrec) loops, \(inUseCount) occupied, \(availableCount) available, \(lockedCount) locked", level: 31)
            }

            cLrec += 1
            guard let c = GridCell.getRandomEmptyCell().lock(require: false) as? HotKey else { continue }
            randomGridCell = c
        } while randomGridCell == nil

        return randomGridCell!
    }
}
