import SpriteKit

final class MoveStepper: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(flags: [], block: launch_)
    }

    func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    private func launch_() { moveStepper() }

    func moveStepper() {
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
