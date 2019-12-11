import Dispatch

final class Disengage: Dispatchable {
    internal override func launch_() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        Log.L.write("disengage \(six(st.name))", level: 31)

        Log.L.write("Reset engagerKey #0", level: 41)
        ch.engagerKey = nil
        ch.cellTaxi = nil

        dp.engage()
    }

}
