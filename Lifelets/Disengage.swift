import Dispatch

final class Disengage: Dispatchable {
    internal override func launch() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        Log.L.write("Disengage1 at \(ch.engagerKey?.gridPosition ?? AKPoint.zero) for \(six(st.name))", level: 71)
        Debug.debugColor(st, .cyan, .cyan)

        Grid.shared.serialQueue.async {
            Log.L.write("Disengage2 at \(ch.engagerKey?.gridPosition ?? AKPoint.zero) for \(six(st.name))", level: 71)
            precondition(ch.engagerKey != nil)
            ch.engagerKey = nil
            Log.L.write("Disengage3 at \(ch.engagerKey?.gridPosition ?? AKPoint.zero) for \(six(st.name))", level: 71)
            dp.engage()
        }
    }

}
