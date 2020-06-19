import SpriteKit

final class MoveStepper: Dispatchable {
    internal override func launch() { moveStepper() }

    func moveStepper() {
        Debug.debugColor(stepper, .brown, .purple)

        stepper!.cJumps += 1    // We count it as a jump even if we don't move

        let js = stepper.jumpSpec!

        let fromIx =    js.fromCell.absoluteIndex
        let toLocalIx = js.toLocalIndex
        let toIx =      js.toCell.absoluteIndex

        let fromContents = stepper.sensorPad.getContents(in: fromIx)
        let toContents = stepper.sensorPad.getContents(in: toIx)

        hardAssert(fromContents == .arkon) { "fromWrong" }
        hardAssert(toContents != .arkon) { "toWrong" }

        Grid.shared.moveArkon(
            stepper, fromCell: js.fromCell, toCell: js.toCell
        )

        stepper.gridCellAbsoluteIndex = toIx
        stepper.sensorPad.unsafeCellConnectors[toLocalIx] = GridCellConnector(js.toCell)

        if toContents == .manna {
            Debug.log(level: 192) { "moveStepper -> arrive" }
            stepper.dispatch.arrive()
            return
        }

        stepper.dispatch.disengageGrid()
    }
}
