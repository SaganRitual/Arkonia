import Dispatch

final class ReleaseStage: Dispatchable {
    internal override func launch_() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }
        guard let taxi = ch.cellTaxi else { preconditionFailure() }

        ch.cellConnector = taxi.toCell
        dp.metabolize()
    }
}
