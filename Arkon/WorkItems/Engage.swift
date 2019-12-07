import Dispatch

final class Engage: Dispatchable {
    internal override func launch_() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

        let cellConnector = gc.lock(require: false)

        if !(cellConnector is HotKey) {
            Log.L.write("ColdKey \(six(st.name))", level: 40)
            if cellConnector is ColdKey {
//                st.nose.color = .blue
                Grid.shared.serialQueue.asyncAfter(deadline: .now() + 0.01) {
                    Log.L.write("re-engage \(six(st.name))", level: 40)
                    st.nose.color = .green
                    dp.disengage()
                    st.nose.color = .red
                }
            }
            return
        }

        guard let cc = cellConnector as? HotKey else { preconditionFailure() }
        Log.L.write("HotKey \(six(st.name))", level: 37)
        ch.cellConnector = cc
        ch.worldStats = World.stats.copy()

        dp.funge()
    }
}
