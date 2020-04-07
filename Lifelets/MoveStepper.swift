import SpriteKit

final class MoveStepper: Dispatchable {
    internal override func launch() { Grid.arkonsPlaneQueue.async(execute: moveStepper) }

    func moveStepper() {
        guard let shuttle = scratch.cellShuttle else { preconditionFailure() }
        Debug.log(level: 156) { "MoveStepper \(six(scratch.stepper.name))" }

        scratch.stepper.previousShiftOffset = scratch.stepper.gridCell.gridPosition
        scratch.stepper.gridCell = shuttle.toCell
        scratch.engagerKey = shuttle.toCell

        shuttle.move()

        Debug.log(level: 154) { "set3 \(six(scratch.stepper.name)) gridCell before \(scratch.stepper.gridCell.gridPosition)" }

//        let other = stepper.gridCell.sprite?.getStepper(require: false)

//        print                ("MoveStepper"
//        + " stepper \(six(stepper.name))"
//        + " sprite \(six(stepper.sprite?.name))"
//        + " gridCell \(stepper.gridCell.gridPosition)"
//        + " lock owner \(six(stepper.gridCell.ownerName))"
//        + " cell occupier sprite \(six(stepper.gridCell.sprite?.name))"
//        + " other stepper \(six(other?.name))"
//        + " other sprite \(six(other?.sprite?.name))"
//        + " other gridCell \(other?.gridCell.gridPosition ?? AKPoint(x: 4242, y: -4242))")

        self.postMove(shuttle)
    }
}

extension MoveStepper {
    func postMove(_ shuttle: CellShuttle) {
        Debug.log(level: 156) { "postMove" }
        let isEdible = scratch.stepper.gridCell.stepper != nil || scratch.stepper.gridCell.manna != nil

        if shuttle.didMove && isEdible {
            Debug.log(level: 156) { "post move to arrive" }
            scratch.dispatch!.arrive()
            return
        }

        Debug.log(level: 156) { "post move to releaseshuttle" }
        scratch.dispatch!.releaseShuttle()
    }
}
