import Dispatch

enum DebugEngage {
    case nothing, entry, notHotKey, coldKey, running, returned
}

final class Engage: Dispatchable {
    static var serializer = 0

    internal override func launch() {
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        guard let gc = st.gridCell else { fatalError() }

        precondition(
            (ch.engagerKey == nil  ||
                (ch.engagerKey?.sprite?.getStepper(require: false)?.name == st.name &&
                ch.engagerKey?.gridPosition == st.gridCell.gridPosition &&
                ch.engagerKey?.sprite?.getStepper(require: false)?.gridCell.gridPosition == st.gridCell.gridPosition)
        ))

        ch.serializer = Engage.serializer
        Engage.serializer += 1

        Debug.debugColor(st, .magenta, .magenta)

        gc.lock(require: false, ownerName: st.name) { ch.engagerKey = $0 }

        if ch.engagerKey is ColdKey {
            writeDebug(
                "Reschedule \(six(st.name)) for \(gc)",
                scratch: ch, level: 64
            )

            gc.reschedule(st)
            return
        }

        Log.L.write("Hot key \(six(st.name)) at \(ch.engagerKey!.gridPosition)", level: 62)

        precondition(ch.engagerKey?.sprite?.getStepper(require: false) != nil)
        precondition(
            (ch.engagerKey == nil  ||
                (ch.engagerKey?.sprite?.getStepper(require: false)?.name == st.name &&
                ch.engagerKey?.gridPosition == st.gridCell.gridPosition &&
                ch.engagerKey?.sprite?.getStepper(require: false)?.gridCell.gridPosition == st.gridCell.gridPosition)
        ))

        dp.funge()
    }
}
