import Dispatch
import SpriteKit

final class DisengageGrid: Dispatchable {
    internal override func launch() { disengageGrid() }

    private func disengageGrid() {
        Debug.debugColor(stepper, .blue, .blue)

        guard let jumpedTo = stepper.jumpSpec?.toLocalIndex else {
            stepper.dispatch.engageGrid(); return
        }

        stepper.sensorPad.disengageGrid(jumpedTo) {
            self.stepper.jumpSpec = nil
            self.stepper.dispatch.engageGrid()
        }
    }
}
