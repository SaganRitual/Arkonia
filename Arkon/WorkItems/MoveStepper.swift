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
        Log.L.write("MoveStepper.launch1_ \(six(scratch?.stepper?.name))", level : 15)
        guard let (ch, _, stepper) = scratch?.getKeypoints() else { fatalError() }

        defer { postMove() }

        guard let stage = ch.getStageConnector(require: false) else { return }

        stage.move()

        stepper.gridCell = GridCell.at(stage.toCell)
        Log.L.write("MoveStepper.launch2_ \(six(scratch?.stepper?.name)) owned by \(stage.toCell.gridPosition)", level : 7)
    }
}

extension MoveStepper {
    func postMove() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }

        if ch.getStageConnector()?.toCell.contents.isEdible() ?? false {
            dp.arrive()
            return
        }

        dp.releaseStage()
    }
}
