import Dispatch

final class Disengage: Dispatchable {
    internal override func launch() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        Debug.log("Disengage1 at \(ch.engagerKey?.gridPosition ?? AKPoint.zero) for \(six(st.name))", level: 71)
        Debug.debugColor(st, .cyan, .cyan)

        Substrate.serialQueue.async {
            Debug.log("Disengage2 at \(ch.engagerKey?.gridPosition ?? AKPoint.zero) for \(six(st.name))", level: 71)
            ch.cellShuttle?.toCell = nil
            ch.cellShuttle?.fromCell = nil
            ch.cellShuttle = nil

            if let gc = ch.engagerKey as? HotKey { gc.ownerName = "" }
            ch.engagerKey = nil // Will already be nil if we're coming here from reengage
            Debug.log("Disengage3 at \(ch.engagerKey?.gridPosition ?? AKPoint.zero) for \(six(st.name))", level: 71)
            dp.engage()
        }
    }

}
