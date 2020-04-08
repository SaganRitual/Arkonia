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
        assert(scratch.engagerKey != nil || scratch.isSpawning || scratch.isRescheduled)

        scratch.engagerKey?.releaseLock(catchDumbMistakes)

        Debug.log(level: 168) { "Disengage \(scratch.stepper.name) at \(six(scratch.engagerKey?.gridPosition))" }
        Debug.debugColor(scratch.stepper, .cyan, .cyan)

        scratch.engagerKey = nil
        scratch.isSpawning = false
        scratch.isRescheduled = false

        scratch.dispatch!.engage()
    }
}
