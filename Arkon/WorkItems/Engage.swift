import Dispatch

enum DebugEngage {
    case nothing, entry, notHotKey, coldKey, running, returned
}

final class Engage: Dispatchable {
    internal override func launch_() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

//        precondition(gc.ownerName != st.name)
        precondition(ch.cellConnector == nil)
        let cellConnector = gc.lock(require: false)

        ch.debugEngage = .entry
        if !(cellConnector is HotKey) {
            ch.debugEngageCRetry += 1
            ch.debugEngage = .notHotKey

//            Log.L.write("ColdKey \(six(st.name))", level: 41)

            if cellConnector is ColdKey {
                ch.debugEngage = .coldKey
                st.nose.color = .blue

                Grid.shared.serialQueue.asyncAfter(deadline: .now() + 0.1) {

                    Log.L.write("retry \(six(st.name)) at \(gc.gridPosition) \(st.gridCell.gridPosition) retry = \(ch.debugEngageCRetry); owned by \(gc.ownerName)", level: 41)

                    ch.debugEngage = .running
                    st.nose.color = .green

                    dp.disengage()

                    st.nose.color = .red
                    ch.debugEngage = .returned
                }
            }
            return
        }

        guard let cc = cellConnector as? HotKey else { preconditionFailure() }
        if ch.debugEngageCRetry > 0 {
            Log.L.write("HotKey \(six(st.name)) at \(st.gridCell.gridPosition) recovers after \(ch.debugEngageCRetry) tries", level: 41)
        }
        ch.debugEngageCRetry = 0
        Log.L.write("Reset cellConnector #1", level: 41)
        ch.cellConnector = cc
        ch.worldStats = World.stats.copy()
        cc.cell.ownerName = st.name

        dp.funge()
    }
}
