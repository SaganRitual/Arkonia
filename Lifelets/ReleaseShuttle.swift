import Dispatch

final class ReleaseShuttle: Dispatchable {
    internal override func launch() {
        Grid.arkonsPlaneQueue.async { self.releaseShuttle(.arkonsPlane) }
    }

    private func releaseShuttle(_ catchDumbMistakes: DispatchQueueID) {
        guard let shuttle = scratch.cellShuttle else { fatalError() }

        Debug.debugColor(scratch.stepper, .green, .cyan)

        assert(shuttle.didMove == (shuttle.fromCell != nil))
        shuttle.fromCell?.releaseLock(catchDumbMistakes) // If we didn't move, there won't be a fromCell
        shuttle.fromCell = nil

        // We don't release the lock on the toCell, because that's the cell we're
        // standing on at te moment. Let the disengage lifelet take care of that
//        shuttle.toCell!.releaseLock()

        assert(shuttle.toCell != nil && shuttle.toCell!.isLocked && shuttle.toCell!.ownerName == scratch.stepper.name)

        shuttle.toCell = nil
        scratch.cellShuttle = nil

        Debug.log(level: 157) { "ReleaseShuttle \(six(scratch.name)) nil -> \(scratch.cellShuttle == nil)" }

        assert(scratch.senseGrid?.cells.isEmpty ?? false)
        scratch.senseGrid = nil

        scratch.dispatch!.metabolize()
    }
}
