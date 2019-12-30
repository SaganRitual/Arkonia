import SpriteKit

final class MoveStepper: Dispatchable {
    internal override func launch() { moveStepper() }

    func moveStepper() {
        guard let (ch, _, stepper) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { preconditionFailure() }
        Log.L.write("MoveStepper \(six(stepper.name))", level: 71)

        shuttle.move()

        stepper.previousShiftOffset = stepper.gridCell.gridPosition
        stepper.gridCell = shuttle.toCell?.bell

        postMove(shuttle)
    }
}

extension MoveStepper {
    func postMove(_ shuttle: CellShuttle) {
        guard let (_, dp, _) = scratch?.getKeypoints() else { fatalError() }

        if shuttle.didMove && shuttle.consumedContents.isEdible() {
            dp.arrive()
            return
        }

        dp.releaseStage()
    }
}
