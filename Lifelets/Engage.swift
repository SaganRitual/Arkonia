import Dispatch

enum DebugEngage {
    case nothing, entry, notHotKey, coldKey, running, returned
}

final class Engage: Dispatchable {
    internal override func launch() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }
        Debug.log("Engage \(six(st.name))", level: 71)

        Debug.debugColor(st, .magenta, .magenta)

        WorkItems.getLock(
            at: gc, for: st, require: .degradeToCold, rescheduleIf: true
        ) { key in
            if key is HotKey {
                ch.engagerKey = key
                Debug.log("Got HotKey for \(six(st.name))", level: 71)
                dp.funge()
            }
        }
    }
}

extension WorkItems {
    typealias OnCompleteKey = (GridCellKey?) -> Void

    static func getLock(
        at cell: GridCell, for stepper: Stepper, require: GridCell.RequireLock,
        rescheduleIf: Bool = true, _ onComplete: @escaping OnCompleteKey
    ) {
        Substrate.serialQueue.async {
            onComplete(cell.getLock(for: stepper, require, rescheduleIf))
        }
    }
}

extension GridCell {
    func getLock(for stepper: Stepper, _ require: RequireLock, _ rescheduleIf: Bool) -> GridCellKey? {
        let key = lock(require: require, ownerName: stepper.name)

        if key is ColdKey && rescheduleIf { reschedule(stepper) }
        return key
    }

    func getLock(ownerName: String, _ require: RequireLock) -> GridCellKey? {
        return lock(require: require, ownerName: ownerName)
    }
}
