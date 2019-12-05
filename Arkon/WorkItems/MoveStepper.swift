import SpriteKit

final class MoveStepper: Dispatchable {
    deinit {
        Log.L.write("~MoveStepper", level : 4)
    }

    internal override func launch_() { moveStepper() }

    func moveStepper() {
        guard let (ch, _, stepper) = scratch?.getKeypoints() else { fatalError() }
        guard let taxi = ch.cellTaxi else { preconditionFailure() }

        taxi.move()

        stepper.previousShiftOffset = stepper.gridCell.gridPosition
        stepper.gridCell = taxi.toCell?.cell
        precondition(stepper.gridCell != nil)

        postMove(taxi)
    }
}

extension MoveStepper {
    func postMove(_ taxi: CellTaxi) {
        guard let (_, dp, _) = scratch?.getKeypoints() else { fatalError() }

        precondition(taxi.fromCell?.cell.gridPosition != taxi.toCell?.cell.gridPosition)

        if taxi.didMove && taxi.consumedContents.isEdible() {
            dp.arrive()
            return
        }

        dp.releaseStage()
    }
}
