import Dispatch

final class ReleaseStage: Dispatchable {
    internal override func launch_() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }
        guard let taxi = ch.cellTaxi_ else { preconditionFailure() }

        Log.L.write("Reset cellConnector #7", level: 41)
        ch.cellConnector_ = taxi.toCell
        dp.metabolize()
    }
}
