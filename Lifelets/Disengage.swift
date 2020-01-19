import Dispatch

final class Disengage: Dispatchable {
    internal override func launch() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        Debug.log("Disengage1 at \(ch.engagerKey?.gridPosition ?? AKPoint.zero) for \(six(st.name))", level: 85)
        Debug.debugColor(st, .cyan, .cyan)

        Substrate.serialQueue.async {
            Debug.log("Disengage2 at \(ch.engagerKey?.gridPosition ?? AKPoint.zero) for \(six(st.name))", level: 85)
            ch.cellShuttle?.toCell = nil
            ch.cellShuttle?.fromCell = nil
            ch.cellShuttle = nil
            ch.senseGrid = nil

            (ch.engagerKey as? HotKey)?.releaseLock()
            ch.engagerKey = nil // Will already be nil if we're coming here from reengage
            Debug.log("Disengage3 at \(ch.engagerKey?.gridPosition ?? AKPoint.zero) for \(six(st.name))", level: 85)
            dp.engage()
            Debug.log("Disengage4 at \(ch.engagerKey?.gridPosition ?? AKPoint.zero) for \(six(st.name))", level: 85)
        }
    }

}
