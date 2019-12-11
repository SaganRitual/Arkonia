import Dispatch

final class ReleaseStage: Dispatchable {
    internal override func launch_() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }
        guard let taxi = ch.cellTaxi else { preconditionFailure() }

        Log.L.write("Reset engagerKey #7", level: 41)
        ch.engagerKey = taxi.toCell
        ch.cellTaxi = nil
        dp.metabolize()
    }
}
