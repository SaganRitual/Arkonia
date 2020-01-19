import Dispatch

final class ReleaseStage: Dispatchable {
    internal override func launch() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { preconditionFailure() }
        guard let toCell = shuttle.toCell else { preconditionFailure() }
        Debug.log("ReleaseStage \(six(st.name))", level: 86)

        Debug.debugColor(st, .green, .cyan)

        Substrate.serialQueue.async {
            ch.engagerKey = toCell
            shuttle.fromCell = nil
            shuttle.toCell = nil
            ch.cellShuttle = nil
            dp.metabolize()
        }
    }
}