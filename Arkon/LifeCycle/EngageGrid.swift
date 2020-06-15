import Dispatch

final class EngageGrid: Dispatchable {
    internal override func launch() { engageGrid() }

    private func engageGrid() {
        Debug.debugColor(stepper, .red, .yellow)
        Debug.log(level: 195) { "engage \(stepper!.name)" }

        let engagerSpec = EngagerSpec(
            stepper.net.netStructure.sensorPadCCells,
            stepper.ingridCellAbsoluteIndex,
            stepper.sensorPad, self.tickLife
        )

        Ingrid.shared.engageSensorPad(engagerSpec)
    }

    private func tickLife() {
        Debug.debugColor(stepper, .red, .green)
        stepper.dispatch!.tickLife()
    }
}
