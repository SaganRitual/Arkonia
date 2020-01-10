import Dispatch

enum DebugEngage {
    case nothing, entry, notHotKey, coldKey, running, returned
}

final class Engage: Dispatchable {
    internal override func launch() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }
        Debug.log("Engage \(six(st.name))", level: 78)

        Debug.debugColor(st, .magenta, .magenta)

        WorkItems.getLock(
            at: gc, for: st, require: .degradeToCold, rescheduleIf: true
        ) { key in
            if key is HotKey {
                ch.engagerKey = key
                Debug.log("Got HotKey for \(six(st.name))", level: 78)
                dp.funge()
            }

            Debug.log("Got \(type(of: key!)) Key for \(six(st.name))", level: 78)
        }
    }
}

extension WorkItems {
    typealias OnCompleteKey = (GridCellKey?) -> Void

    static func getLock(
        at cell: GridCell, for stepper: Stepper, require: GridCell.RequireLock,
        rescheduleIf: Bool = true, _ onComplete: @escaping OnCompleteKey
    ) {
        Debug.log("getLock1 at \(cell) for \(six(stepper.name))", level: 78)
        Substrate.serialQueue.async {
            Debug.log("getLock2 at \(cell) for \(six(stepper.name))", level: 78)
            let gl = cell.getLock(for: stepper, require, rescheduleIf)
            Debug.log("getLock3 at \(cell) for \(six(stepper.name))", level: 78)
            onComplete(gl)
        }
    }
}

extension GridCell {
    func getLock(for stepper: Stepper, _ require: RequireLock, _ rescheduleIf: Bool) -> GridCellKey? {
        let key = lock(require: require, ownerName: stepper.name)
        Debug.log("getLock4 for \(six(stepper.name))", level: 78)

        if key is ColdKey && rescheduleIf { reschedule(stepper) }
        return key
    }

    func getLock(ownerName: String, _ require: RequireLock) -> GridCellKey? {
        Debug.log("getLock5 for \(six(ownerName))", level: 78)
        return lock(require: require, ownerName: ownerName)
    }
}
