import SpriteKit

final class MoveStepper: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("MoveStepper()", level: 3)
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    deinit {
        Log.L.write("~MoveStepper", level : 4)
    }

    private func launch_() { moveStepper() }

    func moveStepper() {
        Log.L.write("MoveStepper.launch1_ \(six(scratch?.stepper?.name))", level : 21)
        guard let (ch, _, stepper) = scratch?.getKeypoints() else { fatalError() }
        stepper.nose.color = .purple

        defer { postMove() }

        guard let stage = ch.getStageConnector() else { preconditionFailure() }

        stage.move()

        stepper.gridCell = GridCell.at(stage.toCell)
        Log.L.write("MoveStepper for \(six(scratch?.stepper?.name)) from \(stage.fromCell?.gridPosition ?? AKPoint.zero) to \(stage.toCell.gridPosition)", level : 21)
    }
}

extension MoveStepper {
    func postMove() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }

        let stage = ch.getStageConnector()

        precondition(stage?.fromCell?.gridPosition != stage?.toCell.gridPosition)

        if (stage?.didMove ?? false) && (stage?.consumedContents.isEdible() ?? false) {
            dp.arrive()
            return
        }

        dp.releaseStage()
    }
}
