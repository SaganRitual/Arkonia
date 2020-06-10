import Dispatch

final class EngageGrid: Dispatchable {
    internal override func launch() { engageGrid() }

    private func engageGrid() {
        Debug.debugColor(stepper, .red, .yellow)
        Debug.log(level: 192) { "engage" }

        let engagerSpec = EngagerSpec(
            cCellsInRange: stepper.net.netStructure.cCellsWithinSenseRange,
            center: stepper.ingridCellAbsoluteIndex, onComplete: tickLife,
            pad: stepper.sensorPad
        )

        Ingrid.shared.engageSensorPad(engagerSpec)
    }

    private func tickLife() {
        Debug.debugColor(stepper, .red, .green)
        stepper.dispatch!.tickLife()
    }
}
