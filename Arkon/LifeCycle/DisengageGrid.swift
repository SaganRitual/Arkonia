import Dispatch
import SpriteKit

final class DisengageGrid: Dispatchable {
    internal override func launch() { disengageGrid() }

    private func disengageGrid() {
        Debug.log(level: 197) { "disengage \(six(stepper?.name))" }
        Debug.debugColor(stepper, .blue, .blue)

        stepper.jumpSpec = nil  // For tidiness and superstition

        Ingrid.shared.disengageSensorPad(
            stepper.sensorPad,
            padCCells: stepper.net.netStructure.cCellsWithinSenseRange,
            keepTheseCells: []
        ) { self.stepper.dispatch!.engageGrid() }
    }
}
