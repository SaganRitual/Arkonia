import CoreGraphics

extension GridCell {
    static func getRandomCell() -> GridCell {
        let wp = Grid.shared.wGrid - 3, hp = Grid.shared.hGrid - 3
        let ak = AKPoint.random(-wp..<wp, -hp..<hp)

        return GridCell.at(ak.x, ak.y)
    }

    static func getRandomEmptyCell(_ onComplete: @escaping (GridCell) -> Void) {
        Grid.arkonsPlaneQueue.async { onComplete(getRandomEmptyCell()) }
    }

    static func getRandomEmptyCell() -> GridCell {
        var randomCell: GridCell?

        repeat { randomCell = getRandomCell() } while randomCell?.stepper != nil

        return randomCell!
    }

    static func lockBirthPosition(parent: Stepper, name: String, _ onComplete: @escaping (HotKey?) -> Void) {
        Grid.arkonsPlaneQueue.async {
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
        Grid.arkonsPlaneQueue.async {
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

            Debug.log(level: 109) { "set2 \(six(ownerName))" }
            randomGridCell = hk
        } while randomGridCell == nil

        return randomGridCell!
    }
}
