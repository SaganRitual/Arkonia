import Dispatch

final class Engage: Dispatchable {
    private(set) var engagerKey: GridCellKey!
    private(set) var cellSenseGrid: CellSenseGrid!

    internal override func launch() { engage() }
}

extension Engage {
    private func engage() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }

        Debug.log(level: 104) { "Engage \(six(st.name)) \(st.gridCell!.contents) at \(st.gridCell.gridPosition)" }
        Debug.debugColor(st, .magenta, .magenta)

        var age: Int = 0
        var aligned = false
        var clock: Int = 0

        func a() { Clock.dispatchQueue.async(execute: b) }

        func b() {
            clock = Clock.shared.worldClock
            WorkItems.getAge(of: st.name, at: clock) { age = $0; c()}
        }

        func c() {
            if ch.spreading > 0 {
                Debug.log(level: 153) { "Temp skipping \(six(st.name)), clock \(clock), age \(age)" }
                ch.spreading -= 1
                dp.disengage(); return
            }

            Debug.log(level: 153) { "Not skipping \(six(st.name)), clock \(clock), age \(age)" }
            d()
        }

        func d() { Grid.serialQueue.async(execute: e) }

        func e() {
            ch.spreading = ch.spreader
            let isEngaged = self.engage_()
            guard isEngaged else {
                Debug.log(level: 153) { "Engage failed for \(six(st.name))" }
                return
            }

            self.makeSenseGrid()
            dp.funge()
        }

        a()
    }

    private func engage_() -> Bool {
        guard let (ch, _, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

        assert(engagerKey == nil)
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

        Debug.log(level: 105) {
            "senseGrid1 \(hk.gridPosition) \(hk.contents) \(st.name)"
        }
        assert(hk.contents == .arkon)

        ch.senseGrid = CellSenseGrid(
            from: hk, by: Arkonia.cSenseGridlets, block: st.previousShiftOffset
        )

        Debug.log(level: 105) {
            let m = ch.senseGrid!.cells.map { "\($0.gridPosition) \(type(of: $0)) \($0.contents)" }
            return "senseGrid0 \(m)"
        }

        assert(ch.senseGrid!.cells[0].contents == .arkon)
        assert(ch.senseGrid!.cells[0].sprite?.name ?? "goof" == st.name)
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
