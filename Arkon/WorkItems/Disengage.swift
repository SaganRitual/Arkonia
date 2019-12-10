import Dispatch

final class Disengage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    func launch_() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        Log.L.write("disengage \(six(st.name))", level: 31)

        ch.cellConnector = nil
        ch.cellTaxi = nil

        dp.engage()
    }

}
