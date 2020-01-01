import Dispatch

final class ReleaseStage: Dispatchable {
    internal override func launch() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { preconditionFailure() }
        guard let toCell = shuttle.toCell else { preconditionFailure() }
        Log.L.write("ReleaseStage \(six(st.name))", level: 71)

        Debug.debugColor(st, .green, .cyan)

        Grid.serialQueue.async {
            ch.engagerKey = toCell
            shuttle.fromCell = nil
            shuttle.toCell = nil
            ch.cellShuttle = nil
            dp.metabolize()
        }
    }
}
