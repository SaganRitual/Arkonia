import Dispatch

final class Disengage: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        Log.L.write("Disengage \(six(scratch.stepper?.name))", level: 28)
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    func launch_() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }

        st.nose.color = .blue

        Log.L.write("Disengage.launch1 \(six(st.name)), \(ch.getStageConnector()?.toCell.gridPosition ?? AKPoint.zero)", level: 28)

        ch.resetGridConnector()
        Log.L.write("Disengage.launch2  \(six(st.name)), \(ch.getStageConnector()?.toCell.gridPosition ?? AKPoint.zero)", level: 28)
        precondition(ch.isEngaged == false)
        dp.engage()
    }

}
