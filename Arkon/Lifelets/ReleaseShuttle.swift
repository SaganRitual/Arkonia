import Dispatch

final class ReleaseShuttle: Dispatchable {
    internal override func launch() {
        Grid.arkonsPlaneQueue.async { self.releaseShuttle(.arkonsPlane) }
    }

    private func releaseShuttle(_ catchDumbMistakes: DispatchQueueID) {
        let shuttle = (scratch.cellShuttle)!

        Debug.debugColor(scratch.stepper, .brown, .yellow)

        hardAssert(shuttle.didMove == (shuttle.fromCell != nil), "hardAssert at \(#file):\(#line)")
        shuttle.fromCell?.releaseLock(catchDumbMistakes) // If we didn't move, there won't be a fromCell
        shuttle.fromCell = nil

        // We don't release the lock on the toCell, because that's the cell we're
        // standing on at te moment. Let the disengage lifelet take care of that
//        shuttle.toCell!.releaseLock()

        hardAssert(
            shuttle.toCell != nil && shuttle.toCell!.isLocked && shuttle.toCell!.ownerName == scratch.stepper.name,
            "hardAssert at \(#file):\(#line)"
        )

        shuttle.toCell = nil
        scratch.cellShuttle = nil
        scratch.senseGrid!.reset(catchDumbMistakes)

        Debug.log(level: 157) { "ReleaseShuttle \(six(scratch.name)) nil -> \(scratch.cellShuttle == nil)" }

        scratch.dispatch!.disengage()
    }
}
