import Dispatch
import SpriteKit

final class DisengageGrid: Dispatchable {
    internal override func launch() { disengageGrid() }

    private func disengageGrid() {
        Debug.debugColor(stepper, .blue, .yellow)

        self.stepper.jumpSpec = nil

        stepper.sensorPad.disengageGrid()
        self.stepper.dispatch.engageGrid()
    }
}
