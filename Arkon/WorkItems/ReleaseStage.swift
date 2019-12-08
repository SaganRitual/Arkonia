import Dispatch

final class ReleaseStage: Dispatchable {
    internal override func launch_() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }
        guard let taxi = ch.cellTaxi else { preconditionFailure() }

        Log.L.write("Reset cellConnector #7", level: 41)
        ch.cellConnector = taxi.toCell
        dp.metabolize()
    }
}
