import Dispatch

enum DebugEngage {
    case nothing, entry, notHotKey, coldKey, running, returned
}

final class Engage: Dispatchable {
    internal override func launch() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

        Debug.debugColor(st, .magenta, .magenta)

        WorkItems.getLock(at: gc, for: st, require: .degradeToCold) {
            ch.engagerKey = $0
            if ch.engagerKey is HotKey { dp.funge() }
        }
    }
}

extension WorkItems {
    typealias OnCompleteKey = (GridCellKey?) -> Void

    static func getLock(
        at cell: GridCell, for stepper: Stepper, require: GridCell.RequireLock,
        _ onComplete: @escaping OnCompleteKey
    ) {
        Grid.shared.serialQueue.async {
            onComplete(cell.getLock(for: stepper, require: .degradeToCold))
        }
    }
}

extension GridCell {
    func getLock(for stepper: Stepper, require: RequireLock) -> GridCellKey? {
        let key = lock(require: require, ownerName: stepper.name)

        if key is ColdKey { reschedule(stepper) }
        return key
    }
}
