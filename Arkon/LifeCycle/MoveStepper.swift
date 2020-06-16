import SpriteKit

final class MoveStepper: Dispatchable {
    internal override func launch() { moveStepper() }

    func moveStepper() {
        Debug.debugColor(stepper, .brown, .purple)

        Debug.log(level: 195) { "moveStepper \(stepper!.name) at absix \(stepper.ingridCellAbsoluteIndex) "}

        stepper!.cJumps += 1    // We count it as a jump even if we don't move

        let js = stepper.jumpSpec!

        let fromIx =    js.fromCell.absoluteIndex
        let toLocalIx = js.toLocalIndex
        let toIx =      js.toCell.absoluteIndex

        let fromContents = Ingrid.shared.getContents(in: fromIx)
        let toContents = Ingrid.shared.getContents(in: toIx)

        hardAssert(fromContents == .arkon) { "fromWrong" }
        hardAssert(toContents != .arkon) { "toWrong" }

        Debug.log(level: 198) { "moveStepper \(stepper.name) from abs ix \(fromIx)(\(fromContents)) to \(toIx)(\(toContents))" }

        Ingrid.shared.moveArkon(
            stepper, fromCell: js.fromCell, toCell: js.toCell
        )

        stepper.ingridCellAbsoluteIndex = toIx
        stepper.sensorPad.thePad[toLocalIx] = IngridCellDescriptor(js.toCell)

        if toContents == .manna {
            Debug.log(level: 192) { "moveStepper -> arrive" }
            stepper.dispatch!.arrive()
            return
        }

        Debug.log(level: 198) { "moveStepper -> disengage \(stepper.name)" }
        stepper.dispatch!.disengageGrid()
    }
}
