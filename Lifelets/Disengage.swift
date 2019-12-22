import Dispatch

final class Disengage: Dispatchable {
    internal override func launch() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        debugColor(st, .cyan, .cyan)

        Log.L.write("disengage \(six(st.name))", level: 63)
        Log.L.write("Reset engagerKey #0", level: 41)

        precondition(ch.cellShuttle == nil && ch.engagerKey != nil)

        ch.engagerKey = nil
        dp.engage()
    }

}
