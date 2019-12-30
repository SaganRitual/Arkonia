import CoreGraphics

extension GridCell {
    static func getRandomCell() -> GridCell {
        let wGrid = Grid.dimensions.wGrid
        let hGrid = Grid.dimensions.hGrid

        let wp = wGrid - 5, hp = hGrid - 5
        let ak = AKPoint.random(-wp..<wp, -hp..<hp)

        return GridCell.at(ak.x, ak.y)
    }

    static func getRandomEmptyCell() -> GridCell {
        let randomCell = getRandomCell()
        var resultPoint = randomCell.gridPosition

        for ix in 1... {
            guard let c = GridCell.atIf(resultPoint) else { continue }

            if !c.contents.isOccupied() { break }
            resultPoint = GridCell.getGridPointByIndex(center: randomCell.gridPosition, targetIndex: ix)
         }

        return GridCell.at(resultPoint)
    }

    static var lbp = 0
    static var hlbp = 0
    static func lockBirthPosition(parent: Stepper, name: String) -> HotKey {
        var randomGridCell: HotKey?
        var gridPointIndex = 0

        repeat {
            gridPointIndex += 1

            let p = parent.gridCell.getGridPointByIndex(gridPointIndex)

            guard let hk = GridCell.atIf(p)?.lockIf(ownerName: name)
                else { continue }

            randomGridCell = hk
        } while (randomGridCell?.contents ?? .invalid) != .nothing

        if gridPointIndex > hlbp {
            hlbp = gridPointIndex
            Log.L.write("lockBirthPosition(\(six(name)), highWater = \(hlbp))", level: 70)
        }

        Debug.writeDebug("lockBirthPosition for parent \(six(parent.name)) at \(randomGridCell!.gridPosition)", scratch: parent.dispatch.scratch)
        return randomGridCell!
    }

    static func lockRandomEmptyCell(ownerName: String, _ onComplete: @escaping ((HotKey?) -> Void)) {
        Grid.shared.serialQueue.async {
            let hotKey = lockRandomEmptyCell(ownerName: ownerName)
            onComplete(hotKey)
        }
    }

    static var lrec = 0
    static var hlrec = 0

    static func lockRandomEmptyCell(ownerName: String) -> HotKey? {
        var randomGridCell: HotKey?

        lrec = 0
        repeat {
            lrec += 1
            let r = GridCell.getRandomEmptyCell()
            let ck = r.lock(require: .degradeToCold, ownerName: ownerName)

            guard let hk = ck as? HotKey else { continue }

            randomGridCell = hk
        } while randomGridCell == nil

        if lrec > hlrec {
            hlrec = lrec
            Log.L.write("lockBirthPosition(\(six(ownerName))), highWater = \(hlrec)", level: 70)
        }

        Log.L.write("lockRandomEmptyCell at \(randomGridCell!.gridPosition)", level: 54)
        return randomGridCell!
    }
}
