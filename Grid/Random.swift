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

    static func getRandomEmptyCell() -> GridCell {
        var randomCell: GridCell?

        repeat { randomCell = getRandomCell() } while randomCell?.contents.isOccupied ?? true

        return randomCell!
    }

    static func lockBirthPosition(parent: Stepper, name: String, _ onComplete: @escaping (HotKey?) -> Void) {
        Substrate.serialQueue.async {
            let key = lockBirthPosition(parent: parent, name: name)
            onComplete(key)
        }
    }

    static func lockBirthPosition(parent: Stepper, name: String) -> HotKey? {
        let gridPointIndex = Int.random(in: 0..<Arkonia.cMotorGridlets)
        let p = parent.gridCell.getGridPointByIndex(gridPointIndex)

        return GridCell.atIf(p)?.lockIf(ownerName: name)
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
