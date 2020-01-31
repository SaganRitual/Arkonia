import Dispatch

final class ReleaseShuttle: Dispatchable {
    internal override func launch() {
        Grid.serialQueue.async { self.releaseShuttle() }
    }

    private func releaseShuttle() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { fatalError() }
        guard let toCell = shuttle.toCell else { fatalError() }

        Debug.debugColor(st, .green, .cyan)

        assert(ch.engagerKey == nil)
        ch.engagerKey = toCell

        shuttle.fromCell?.releaseLock() // If we didn't move, there won't be a fromCell
        shuttle.fromCell = nil

        shuttle.toCell!.releaseLock()   // There will always be a toCell
        shuttle.toCell = nil

        ch.cellShuttle = nil
        Debug.log(level: 104) { "ReleaseShuttle \(six(ch.name)) nil -> \(ch.cellShuttle == nil)" }
        ch.senseGrid = nil
        dp.metabolize()
    }
}
