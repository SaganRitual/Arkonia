import Dispatch

final class ReleaseShuttle: Dispatchable {
    internal override func launch() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { preconditionFailure() }
        guard let toCell = shuttle.toCell else { preconditionFailure() }
        Debug.log("ReleaseShuttle \(six(st.name))", level: 86)

        Debug.debugColor(st, .green, .cyan)

        Substrate.serialQueue.async {
            ch.engagerKey = toCell
            shuttle.fromCell = nil
            shuttle.toCell = nil
            ch.cellShuttle = nil
            ch.senseGrid = nil
            dp.metabolize()
        }
    }
}
