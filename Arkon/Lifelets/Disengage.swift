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

        Debug.log(level: 185) {
            "Disengage \(six(scratch?.stepper?.name))"
            + " at \(six(scratch?.engagerKey?.gridPosition))"
            + " owner \(six(scratch?.engagerKey?.ownerName))"
            + " sense center \(six(scratch?.senseGrid?.cells[0]?.gridPosition))"
            + " owner \(six(scratch.senseGrid?.cells[0]?.ownerName))"
        }

        scratch.senseGrid?.cells[0] = SenseGrid.nilKey

        scratch.engagerKey?.releaseLock(catchDumbMistakes)

        scratch.engagerKey = nil
        scratch.isSpawning = false
        scratch.isRescheduled = false

        Debug.debugColor(scratch.stepper, .blue, .blue)

        scratch.dispatch!.engage()
    }
}
