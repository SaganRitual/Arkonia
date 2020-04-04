import Dispatch

final class Engage: Dispatchable {
    internal override func launch() { Grid.arkonsPlaneQueue.async(execute: engage) }

    private func engage() {
        guard let (_, dp, st) = self.scratch?.getKeypoints() else { fatalError() }

        Debug.log(level: 155) { "Engage \(six(st.name)) at \(st.gridCell.gridPosition)" }
        Debug.debugColor(st, .magenta, .magenta)

//        let startTime = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)

        let isEngaged = self.engageIf()
        guard isEngaged else {
            Debug.log(level: 153) { "Engage failed for \(six(st.name))" }
            return
        }

//            let stop = clock_gettime_nsec_np(CLOCK_UPTIME_RAW)
//            let duration = stop - startTime

        self.makeSenseGrid()
        dp.funge()
    }

    private func engageIf() -> Bool {
        guard let (ch, _, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

        let engagerKey = gc.getLock(for: st, .degradeToCold, true)

        if engagerKey is HotKey {
            ch.engagerKey = engagerKey
            return true
        }

        return false
    }

    private func makeSenseGrid() {
        guard let (ch, _, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let hk = ch.engagerKey as? HotKey else { fatalError() }

        Debug.log(level: 105) {
            "senseGrid1 \(hk.gridPosition) \(st.name)"
        }

        ch.senseGrid = CellSenseGrid(
            from: hk, by: Arkonia.cSenseGridlets, block: st.previousShiftOffset
        )

        Debug.log(level: 105) {
            let m = ch.senseGrid!.cells.map { "\($0.gridPosition) \(type(of: $0))" }
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
