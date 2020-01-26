import Dispatch

final class Disengage: Dispatchable {
    internal override func launch() { Substrate.serialQueue.async { self.disengage() } }

    private func disengage() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }

        Debug.debugColor(st, .cyan, .cyan)

//        if st.sprite?.name != st.gridCell.sprite?.name {
//            let other = st.gridCell.sprite?.getStepper(require: false)
//
//            print                ("Disengage"
//            + " stepper \(six(st.name))"
//            + " sprite \(six(st.sprite?.name))"
//            + " gridCell \(st.gridCell.gridPosition)"
//            + " lock owner \(six(st.gridCell.ownerName))"
//            + " cell occupier sprite \(six(st.gridCell.sprite?.name))"
//            + " other stepper \(six(other?.name))"
//            + " other sprite \(six(other?.sprite?.name))"
//            + " other gridCell \(other?.gridCell.gridPosition ?? AKPoint(x: 4242, y: -4242))")
//        }
/*
        Debug.log(level: 109) {
            let other = st.gridCell.sprite?.getStepper(require: false)

            return (st.sprite?.name == st.gridCell.sprite?.name) ? nil :
                ("Disengage"
                + " stepper \(six(st.name))"
                + " sprite \(six(st.sprite?.name))"
                + " gridCell \(st.gridCell.gridPosition)"
                + " lock owner \(six(st.gridCell.ownerName))"
                + " lock owner sprite \(six(st.gridCell.sprite?.name))"
                + " other stepper \(six(other?.name))"
                + " other sprite \(six(other?.sprite?.name))"
                + " other gridCell \(other?.gridCell.gridPosition ?? AKPoint(x: 4242, y: -4242))")
        }
*/
        assert(ch.engagerKey != nil || (ch.cellShuttle?.toCell?.contents ?? .arkon) == .arkon)
        assert(st.sprite === st.gridCell.sprite)// || st.parentStepper?.sprite === st.gridCell.sprite)

        if let fc = ch.cellShuttle?.fromCell { fc.releaseLock() }
        ch.cellShuttle?.fromCell = nil

        if let tc = ch.cellShuttle?.toCell { tc.releaseLock() }
        ch.cellShuttle?.toCell = nil

        ch.senseGrid?.cells.forEach { ($0 as? HotKey)?.releaseLock() }
        ch.senseGrid = nil

        if let hk = ch.engagerKey as? HotKey { hk.releaseLock() }
        ch.engagerKey = nil // Will already be nil if we're coming here from reengage
        dp.engage()
    }
}
