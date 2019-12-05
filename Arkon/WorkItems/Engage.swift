import Dispatch

final class Engage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?
    var counter = 0

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem { [weak self] in self?.launch_() }
    }

    func launch_() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

        let cellConnector = gc.lock(require: false)

        if !(cellConnector is HotKey) {
            Log.L.write("ColdKey \(six(st.name))", level: 31)
            if cellConnector is ColdKey { gc.requesters.append(dp) }
            return
        }

        guard let cc = cellConnector as? HotKey else { preconditionFailure() }
        Log.L.write("HotKey \(six(st.name))", level: 31)
        ch.cellConnector = cc
        ch.worldStats = World.stats.copy()

        dp.funge()
    }
}
