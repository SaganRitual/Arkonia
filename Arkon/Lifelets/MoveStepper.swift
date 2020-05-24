import SpriteKit

final class MoveStepper: Dispatchable {
    internal override func launch() { Grid.arkonsPlaneQueue.async(execute: moveStepper) }

    func moveStepper() {
        Debug.debugColor(scratch.stepper, .brown, .purple)

        let shuttle = scratch.cellShuttle!

        Debug.log(level: 184) { "MoveStepper \(six(scratch.stepper.name)) to \(shuttle.toCell!.gridPosition)" }

        scratch.stepper.previousShiftOffset = scratch.stepper.gridCell.gridPosition
        scratch.stepper.gridCell = shuttle.toCell
        scratch.engagerKey = shuttle.toCell

        shuttle.move()

        Debug.log(level: 184) { "set3 \(six(scratch.stepper.name)) gridCell before \(scratch.stepper.gridCell.gridPosition)" }

        self.postMove(shuttle)
    }
}

extension MoveStepper {
    func postMove(_ shuttle: CellShuttle) {
        Debug.log(level: 184) { "postMove, landed at \(scratch.stepper.gridCell.gridPosition)/\(scratch.stepper.gridCell.scenePosition)" }
        let isEdible = scratch.stepper.gridCell.stepper != nil || scratch.stepper.gridCell.manna != nil

        if shuttle.didMove && isEdible {
            Debug.log(level: 184) { "post move to arrive" }
            scratch.dispatch!.arrive()
            return
        }

        Debug.log(level: 184) { "post move to releaseshuttle" }
        scratch.dispatch!.releaseShuttle()
    }
}
