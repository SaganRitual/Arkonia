import Dispatch

final class Disengage: Dispatchable {
    internal override func launch_() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        Log.L.write("disengage \(six(st.name))", level: 31)

        ch.cellConnector = nil
        ch.cellTaxi = nil

        dp.engage()
    }

}
