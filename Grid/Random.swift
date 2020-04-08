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

    static func lockBirthPosition(parent: Stepper, name: ArkonName, _ catchDumbMistakes: DispatchQueueID, _ onComplete: @escaping (GridCell?) -> Void) {
        Grid.arkonsPlaneQueue.async {
            let key = lockBirthPosition(parent: parent, name: name, catchDumbMistakes)
            onComplete(key)
        }
    }

    static func lockBirthPosition(parent: Stepper, name: ArkonName, _ catchDumbMistakes: DispatchQueueID) -> GridCell? {
        let gridPointIndex = Int.random(in: 0..<Arkonia.cMotorGridlets)
        let p = parent.gridCell.getGridPointByIndex(gridPointIndex)

        return GridCell.atIf(p)?.lockIf(ownerName: name, catchDumbMistakes)
    }

    static func lockRandomEmptyCell(ownerName: ArkonName, _ catchDumbMistakes: DispatchQueueID, _ onComplete: @escaping ((GridCell?) -> Void)) {
        Grid.arkonsPlaneQueue.async {
            let hotKey = lockRandomEmptyCell(ownerName: ownerName, catchDumbMistakes)
            onComplete(hotKey)
        }
    }

    static func lockRandomEmptyCell(ownerName: ArkonName, _ catchDumbMistakes: DispatchQueueID) -> GridCell? {
        let randomGridCell = GridCell.getRandomEmptyCell()

        guard let hotKey = randomGridCell.lock(
            require: .degradeToCold, ownerName: ownerName, catchDumbMistakes
        ) as? GridCell else { return nil }

        return hotKey
    }
}
