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

//        shuttle.toCell!.releaseLock()   // There will always be a toCell
//        shuttle.toCell = nil

        scratch.cellShuttle = nil
        Debug.log(level: 157) { "ReleaseShuttle \(six(scratch.name)) nil -> \(scratch.cellShuttle == nil)" }

        // Destructing the sense grid causes the scratch
//        scratch.dispatchQueueID = catchDumbMistakes
        scratch.senseGrid = nil

        scratch.dispatch!.metabolize()
    }
}
