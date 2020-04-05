import Dispatch

final class Engage: Dispatchable {
    internal override func launch() { Grid.arkonsPlaneQueue.async(execute: engage) }

    private func engage() {
        Debug.log(level: 155) { "Engage \(six(scratch.stepper.name)) at \(scratch.stepper.gridCell.gridPosition)" }
        Debug.debugColor(scratch.stepper, .magenta, .magenta)

        let isEngaged = self.engageIf()
        guard isEngaged else {
            Debug.log(level: 153) { "Engage failed for \(six(scratch.stepper.name))" }
            return
        }

        self.makeSenseGrid()
        scratch.dispatch!.tickLife()
    }

    private func engageIf() -> Bool {
        guard let gc = scratch.stepper.gridCell else { fatalError() }

        let engagerKey = gc.getLock(for: scratch.stepper, .degradeToCold, true)

        if engagerKey is HotKey {
            scratch.engagerKey = engagerKey
            return true
        }

        return false
    }

    private func makeSenseGrid() {
        guard let hk = scratch.engagerKey as? HotKey else { fatalError() }

        Debug.log(level: 105) {
            "senseGrid1 \(hk.gridPosition) \(scratch.stepper.name)"
        }

        scratch.senseGrid = CellSenseGrid(
            from: hk, by: Arkonia.cSenseGridlets, block: scratch.stepper.previousShiftOffset
        )

        Debug.log(level: 105) {
            let m = scratch.senseGrid!.cells.map { "\($0.gridPosition) \(type(of: $0))" }
            return "senseGrid0 \(m)"
        }
    }
}

extension GridCell {
    func getLock(for stepper: Stepper, _ require: RequireLock, _ rescheduleIf: Bool) -> GridCellKey? {
        let key = lock(require: require, ownerName: stepper.name)
        Debug.log(level: 85) { "getLock4 for \(six(stepper.name))" }

        if key is ColdKey && rescheduleIf {
            Debug.log(level: 85) { "getLock4.5 for \(six(stepper.name))" }
            reschedule(stepper)
        }

        return key
    }
}
