import Dispatch

final class ReleaseShuttle: Dispatchable {
    internal override func launch() {
        Grid.arkonsPlaneQueue.async { self.releaseShuttle() }
    }

    private func releaseShuttle() {
        guard let shuttle = scratch.cellShuttle else { fatalError() }
        guard let toCell = shuttle.toCell else { fatalError() }

        Debug.debugColor(scratch.stepper, .green, .cyan)

        assert(scratch.engagerKey == nil)
        scratch.engagerKey = toCell

        shuttle.fromCell?.releaseLock() // If we didn't move, there won't be a fromCell
        shuttle.fromCell = nil

        shuttle.toCell!.releaseLock()   // There will always be a toCell
        shuttle.toCell = nil

        scratch.cellShuttle = nil
        Debug.log(level: 156) { "ReleaseShuttle \(six(scratch.name)) nil -> \(scratch.cellShuttle == nil)" }
        scratch.senseGrid = nil
        scratch.dispatch!.metabolize()
    }
}
