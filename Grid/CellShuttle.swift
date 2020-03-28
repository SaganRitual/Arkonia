import SpriteKit

class CellShuttle {
    weak var consumedStepper: Stepper?
    var didMove = false
    var fromCell: HotKey?
    var toCell: HotKey?

    init(_ fromCell: HotKey?, _ toCell: HotKey) {
        self.fromCell = fromCell; self.toCell = toCell
    }

    func move() {
        consumedStepper = nil

        // No fromCell means we didn't move
        guard let f = fromCell?.gridCell else { return }
        guard let t = toCell?.gridCell else { fatalError() }

        assert(f.isLocked && t.isLocked && f.ownerName == t.ownerName)
        assert(f.stepper != nil)

        consumedStepper = t.stepper

        Debug.log(level: 104) { "setContents from CellShuttle.move f \(f.contents) at \(f.gridPosition) t \(t.contents) at \(t.gridPosition)" }

        t.setContents(to: f.stepper)
        f.clearContents()
        self.fromCell?.releaseLock()

        assert(t.stepper != nil)

        self.didMove = true
    }

    func transferKeys(to winner: Stepper, _ onComplete: @escaping (CellShuttle) -> Void) {
        toCell?.transferKey(to: winner) { onComplete(self) }
    }
}
