import SpriteKit

final class MoveStepper: Dispatchable {
    deinit {
        Log.L.write("~MoveStepper", level : 4)
    }

    internal override func launch_() { moveStepper() }

    func moveStepper() {
        guard let (ch, _, stepper) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { preconditionFailure() }

        Log.L.write("moveStepper from \(shuttle.fromCell?.gridPosition ?? AKPoint(x: -4242, y: 4242)) to \(shuttle.toCell?.gridPosition ?? AKPoint(x: -4242, y: 4242))", level: 56)

        shuttle.move()

        stepper.previousShiftOffset = stepper.gridCell.gridPosition
        stepper.gridCell = shuttle.toCell?.getCell()
        precondition(stepper.gridCell != nil)

        postMove(shuttle)
    }
}

extension MoveStepper {
    func postMove(_ shuttle: CellShuttle) {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }

        precondition(
            (ch.cellShuttle?.toCell != nil && ch.cellShuttle?.toCell?.sprite?.name == st.name && ch.engagerKey == nil) ||
                (ch.engagerKey?.sprite?.name == st.name && ch.cellShuttle?.toCell == nil)
        )

        if shuttle.didMove && shuttle.consumedContents.isEdible() {
            if shuttle.consumedContents == .arkon {
                Log.L.write("postMove from \(shuttle.fromCell?.gridPosition ?? AKPoint(x: -4242, y: -4242)) to \(shuttle.toCell?.gridPosition ?? AKPoint(x: -4242, y: -4242)) holding \(shuttle.toCell?.contents ?? .invalid) by \(six(shuttle.toCell?.sprite?.name)) at \(shuttle.toCell?.sprite?.position ?? CGPoint.zero)", level: 56)
            }
            dp.arrive()
            return
        }

        dp.releaseStage()
    }
}
