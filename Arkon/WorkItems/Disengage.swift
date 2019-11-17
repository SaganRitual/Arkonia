import Dispatch

class Disengage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(flags: .barrier, block: launch_)
    }

    func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    func launch_() {
        guard let (_, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let unsafeCell = st.gridCell else { fatalError() }

        assert(unsafeCell.owner == st.name)
        unsafeCell.owner = nil

        dp.engage(self.wiLaunch!)
    }

}
