import Dispatch

final class Engage: Dispatchable {
    private(set) var engagerKey: GridCellKey!
    private(set) var cellSenseGrid: CellSenseGrid!

    internal override func launch() {
        guard let (_, dp, st) = self.scratch?.getKeypoints() else { fatalError() }

        Debug.log("Engage \(six(st.name))", level: 85)
        Debug.debugColor(st, .magenta, .magenta)

        Substrate.serialQueue.async {
            let isEngaged = self.engage()
            guard isEngaged else { return }

            self.makeSenseGrid()
            dp.funge()
        }
    }
}

extension Engage {
    private func engage() -> Bool {
        guard let (ch, _, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

        engagerKey = gc.getLock(for: st, .degradeToCold, true)

        if engagerKey is HotKey {
            ch.engagerKey = engagerKey
            return true
        }

        return false
    }

    private func makeSenseGrid() {
        guard let (ch, _, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let hk = ch.engagerKey as? HotKey else { fatalError() }

        ch.senseGrid = CellSenseGrid(
            from: hk, by: Arkonia.cSenseGridlets, block: st.previousShiftOffset
        )
    }
}

extension GridCell {
    func getLock(for stepper: Stepper, _ require: RequireLock, _ rescheduleIf: Bool) -> GridCellKey? {
        let key = lock(require: require, ownerName: stepper.name)
        Debug.log("getLock4 for \(six(stepper.name))", level: 85)

        if key is ColdKey && rescheduleIf {
            Debug.log("getLock4.5 for \(six(stepper.name))", level: 85)
            reschedule(stepper)
        }

        return key
    }
}
