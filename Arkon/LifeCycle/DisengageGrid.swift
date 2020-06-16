import Dispatch
import SpriteKit

final class DisengageGrid: Dispatchable {
    internal override func launch() { disengageGrid() }

    private func disengageGrid() {
        Debug.debugColor(stepper, .blue, .blue)

        stepper.jumpSpec = nil  // For tidiness and superstition

        stepper.sensorPad.reset()
        stepper.dispatch!.engageGrid()
    }
}
