import Dispatch

final class Disengage: Dispatchable {
    internal override func launch() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        Log.L.write("Disengage1 at \(ch.engagerKey?.gridPosition ?? AKPoint.zero) for \(six(st.name))", level: 71)
        Debug.debugColor(st, .cyan, .cyan)

        Substrate.serialQueue.async {
            Log.L.write("Disengage2 at \(ch.engagerKey?.gridPosition ?? AKPoint.zero) for \(six(st.name))", level: 71)
            ch.cellShuttle?.toCell = nil
            ch.cellShuttle?.fromCell = nil
            ch.cellShuttle = nil

            if let gc = ch.engagerKey as? HotKey { gc.ownerName = "" }
            ch.engagerKey = nil // Will already be nil if we're coming here from reengage
            Log.L.write("Disengage3 at \(ch.engagerKey?.gridPosition ?? AKPoint.zero) for \(six(st.name))", level: 71)
            dp.engage()
        }
    }

}
