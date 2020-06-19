import Dispatch

final class EngageGrid: Dispatchable {
    internal override func launch() { engageGrid() }

    private func engageGrid() {
        Debug.debugColor(stepper, .red, .yellow)
        stepper.sensorPad.engageGrid(center: stepper.gridCellAbsoluteIndex, tickLife)
    }

    private func tickLife() {
        Debug.debugColor(stepper, .red, .green)
        stepper.dispatch.tickLife()
    }
}
