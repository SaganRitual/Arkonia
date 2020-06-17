import Dispatch
import SpriteKit

final class DisengageGrid: Dispatchable {
    internal override func launch() { disengageGrid() }

    private func disengageGrid() {
        Debug.debugColor(stepper, .blue, .yellow)

        if let jumpedTo = stepper.jumpSpec?.toLocalIndex {
            stepper.sensorPad.disengageGrid(jumpedTo)
        }

        self.stepper.jumpSpec = nil
        self.stepper.dispatch.engageGrid()
    }
}
