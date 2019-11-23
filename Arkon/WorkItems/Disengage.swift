import Dispatch

class Disengage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Disengage()", select: 3)
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(flags: .barrier, block: launch_)
    }

    func launch() {
        Log.L.write("Disengage.launch", select: 3)
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    func launch_() {
        Log.L.write("Disengage.launch_", select: 4)
        guard let (_, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let unsafeCell = st.gridCell else { fatalError() }

        precondition(unsafeCell.ownerName == st.name)

        unsafeCell.ownerName = nil
        dp.engage(self.wiLaunch!)
    }

}
