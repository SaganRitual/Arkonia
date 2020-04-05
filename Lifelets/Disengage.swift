import Dispatch

final class Disengage: Dispatchable {
    internal override func launch() { Grid.arkonsPlaneQueue.async { self.disengage() } }

    private func disengage() {
        Debug.log(level: 156) { "Disengage \(scratch.stepper.name)" }
        Debug.debugColor(scratch.stepper, .cyan, .cyan)

        if let fc = scratch.cellShuttle?.fromCell { fc.releaseLock() }
        scratch.cellShuttle?.fromCell = nil

        if let tc = scratch.cellShuttle?.toCell { tc.releaseLock() }
        scratch.cellShuttle?.toCell = nil

        scratch.senseGrid?.cells.forEach { ($0 as? HotKey)?.releaseLock() }
        scratch.senseGrid = nil

        if let hk = scratch.engagerKey as? HotKey { hk.releaseLock() }
        scratch.engagerKey = nil // Will already be nil if we're coming here from reengage
        scratch.dispatch!.engage()
    }
}
