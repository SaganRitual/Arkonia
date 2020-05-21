import SpriteKit

class CellShuttle {
    var didMove = false
    var fromCell: GridCell?
    var toCell: GridCell?

    init(_ fromCell: GridCell?, _ toCell: GridCell) {
        self.fromCell = fromCell; self.toCell = toCell
        Debug.log(level: 167) { "CellShuttle.init fromCell \(six(fromCell)) toCell \(six(toCell))" }
    }

    func move() {
        // No fromCell means we didn't move
        guard let f = fromCell else { return }
        let t = (toCell)!

        Debug.log(level: 167) { "CellShuttle.move fromCell \(six(fromCell)) toCell \(six(toCell))" }
        hardAssert(f.isLocked && t.isLocked && f.ownerName == t.ownerName)
        hardAssert(f.stepper != nil)

        t.stepper = f.stepper
        f.stepper = nil

        hardAssert(t.stepper != nil)

        self.didMove = true
    }

    func transferKeys(to winner: Stepper, _ catchDumbMistakes: DispatchQueueID, _ onComplete: @escaping (CellShuttle) -> Void) {
        toCell?.transferKey(to: winner, catchDumbMistakes) { onComplete(self) }
    }
}

extension GridCell {
    func transferKey(to winner: Stepper, _ catchDumbMistakes: DispatchQueueID, _ onComplete: @escaping () -> Void) {
        hardAssert(self.isLocked)

        Debug.log(level: 71) { "transferKey from \(six(self.ownerName)) at \(gridPosition) to \(six(winner.name))" }

        self.ownerName = winner.name
        self.stepper = winner

        if winner.dispatch.scratch.engagerKey != nil { releaseLock(catchDumbMistakes) }

        onComplete()
    }
}
