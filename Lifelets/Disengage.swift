import Dispatch

final class Disengage: Dispatchable {
    internal override func launch() { Grid.serialQueue.async { self.disengage() } }

    private func disengage() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }

        Debug.log(level: 156) { "Disengage \(st.name)" }
        Debug.debugColor(st, .cyan, .cyan)

        if let fc = ch.cellShuttle?.fromCell { fc.releaseLock() }
        ch.cellShuttle?.fromCell = nil

        if let tc = ch.cellShuttle?.toCell { tc.releaseLock() }
        ch.cellShuttle?.toCell = nil

        ch.senseGrid?.cells.forEach { ($0 as? HotKey)?.releaseLock() }
        ch.senseGrid = nil

        if let hk = ch.engagerKey as? HotKey { hk.releaseLock() }
        ch.engagerKey = nil // Will already be nil if we're coming here from reengage
        dp.engage()
    }
}
