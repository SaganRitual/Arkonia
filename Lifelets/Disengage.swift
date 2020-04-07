import Dispatch

final class Disengage: Dispatchable {
    var catchDumbMistakes = DispatchQueueID.unspecified

    internal override func launch() {
        Grid.arkonsPlaneQueue.async {
            self.catchDumbMistakes = .arkonsPlane
            self.disengage()
            self.catchDumbMistakes = .unspecified
        }
    }

    private func disengage() {
        Debug.log(level: 156) { "Disengage \(scratch.stepper.name)" }
        Debug.debugColor(scratch.stepper, .cyan, .cyan)

        if let fc = scratch.cellShuttle?.fromCell { fc.releaseLock(catchDumbMistakes) }
        scratch.cellShuttle?.fromCell = nil

        if let tc = scratch.cellShuttle?.toCell { tc.releaseLock(catchDumbMistakes) }
        scratch.cellShuttle?.toCell = nil

        scratch.senseGrid?.cells.forEach { ($0 as? GridCell)?.releaseLock(catchDumbMistakes) }
        scratch.senseGrid = nil

        scratch.cellShuttle = nil   // Hmm?

        if let hk = scratch.engagerKey { hk.releaseLock(catchDumbMistakes) }
        scratch.engagerKey = nil // Will already be nil if we're coming here from reengage
        scratch.dispatch!.engage()
    }
}
