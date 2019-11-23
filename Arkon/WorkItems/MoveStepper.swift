import SpriteKit

final class MoveStepper: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("MoveStepper()", select: 3)
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(flags: [], block: launch_)
    }

    deinit {
        Log.L.write("~MoveStepper", select: 4)
    }

    func launch() {
        Log.L.write("MoveStepper.launch", select: 3)
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    private func launch_() { moveStepper() }

    func moveStepper() {
        Log.L.write("MoveStepper.launch_", select: 3)
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }

        let gcc = ch.stage
        gcc.move()

        st.gridCell = GridCell.at(gcc.to)
        postMove()
    }
}

extension MoveStepper {
    func postMove() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }

        if ch.stage.to.contents.isEdible() {
            dp.arrive(wiLaunch!)
            return
        }

        dp.releaseStage(self.wiLaunch!)
    }
}
