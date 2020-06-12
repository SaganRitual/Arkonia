import Dispatch
import SpriteKit

final class DisengageGrid: Dispatchable {
    internal override func launch() { disengageGrid() }

    private func disengageGrid() {
        Debug.debugColor(stepper, .blue, .blue)
        Debug.log(level: 192) { "disengage" }

        stepper.jumpSpec = nil  // For tidiness and superstition

        Ingrid.shared.disengageSensorPad(
            stepper.sensorPad,
            padCCells: stepper.net.netStructure.cCellsWithinSenseRange,
            keepTheseCells: []
        ) { self.stepper.dispatch!.engageGrid() }
    }
}
