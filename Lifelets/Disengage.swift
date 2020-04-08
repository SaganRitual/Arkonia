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

        if let hk = scratch.engagerKey { hk.releaseLock(catchDumbMistakes) }
        scratch.engagerKey = nil

        scratch.dispatch!.engage()
    }
}
