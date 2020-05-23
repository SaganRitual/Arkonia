import Dispatch
import SpriteKit

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
        hardAssert(
            scratch.engagerKey != nil || scratch.isSpawning || scratch.isRescheduled,
            "hardAssert at \(#file):\(#line)"
        )

        scratch.engagerKey?.releaseLock(catchDumbMistakes)

        Debug.log(level: 168) { "Disengage \(scratch.stepper.name) at \(six(scratch.engagerKey?.gridPosition))" }
        Debug.debugColor(scratch.stepper, .blue, .blue)

        scratch.senseGrid?.cells[0] = CellSenseGrid.nilKey
        scratch.engagerKey = nil
        scratch.isSpawning = false
        scratch.isRescheduled = false

        scratch.dispatch!.engage()
    }
}
