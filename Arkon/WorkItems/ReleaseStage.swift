import Dispatch

final class ReleaseStage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem { [weak self] in self?.launch_() }
    }

    func launch_() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }
        guard let taxi = ch.cellTaxi else { preconditionFailure() }

        ch.cellConnector = taxi.toCell
        dp.metabolize()
    }
}
