import Dispatch

enum DebugEngage {
    case nothing, entry, notHotKey, coldKey, running, returned
}

final class Engage: Dispatchable {
    internal override func launch_() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

        Log.L.write("Engage \(six(st.name))", level: 45)
        gc.lock(require: false, ownerName: st.name) { ch.engagerKey = $0 }

        if let ek = ch.engagerKey as? ColdKey {
            Log.L.write("Reschedule \(six(st.name)) for \(gc)", level: 45)
            ek.reschedule(st)
            return
        }

        Log.L.write("Hot key \(six(st.name))", level: 45)
        ch.worldStats = World.stats.copy()
        dp.funge()
    }
}
