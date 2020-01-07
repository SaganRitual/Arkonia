import CoreGraphics

extension GridCell {
    static func getRandomCell() -> GridCell {
        let wp = Substrate.shared.wGrid - 3, hp = Substrate.shared.hGrid - 3
        let ak = AKPoint.random(-wp..<wp, -hp..<hp)

        return GridCell.at(ak.x, ak.y)
    }

    static func getRandomEmptyCell(_ onComplete: @escaping (GridCell) -> Void) {
        Substrate.serialQueue.async { onComplete(getRandomEmptyCell()) }
    }

    static var lbp = 0
    static var hlbp = 0
    static var lrec = 0
    static var hlrec = 0
    static func getRandomEmptyCell() -> GridCell {
        var randomCell: GridCell?

        lrec = 0
        repeat {
            lrec += 1
            randomCell = getRandomCell()

            if lrec > hlrec {
                hlrec = lrec
                Debug.log("lockRandomEmptyCell(\(randomCell!)) highWater = \(hlrec)", level: 72)
            }
        } while randomCell?.contents.isOccupied() ?? true

        return randomCell!
    }

    static func lockBirthPosition(parent: Stepper, name: String, _ onComplete: @escaping (HotKey) -> Void) {
        Substrate.serialQueue.async {
            let key = lockBirthPosition(parent: parent, name: name)
            onComplete(key)
        }
    }

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
            Debug.log("lockBirthPosition(\(six(name)), highWater = \(hlbp))", level: 70)
        }

        Debug.log("lockBirthPosition for parent \(six(parent.name)) at \(randomGridCell!.gridPosition)", level: 75)
        return randomGridCell!
    }

    static func lockRandomEmptyCell(ownerName: String, _ onComplete: @escaping ((HotKey?) -> Void)) {
        Substrate.serialQueue.async {
            let hotKey = lockRandomEmptyCell(ownerName: ownerName)
            onComplete(hotKey)
        }
    }

    static func lockRandomEmptyCell(ownerName: String) -> HotKey? {
        var randomGridCell: HotKey?

        repeat {
            let r = GridCell.getRandomEmptyCell()
            let ck = r.lock(require: .degradeToCold, ownerName: ownerName)

            guard let hk = ck as? HotKey else { continue }

            randomGridCell = hk
        } while randomGridCell == nil

        return randomGridCell!
    }
}
