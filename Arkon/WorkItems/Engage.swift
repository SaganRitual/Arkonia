import Dispatch

enum DebugEngage {
    case nothing, entry, notHotKey, coldKey, running, returned
}

final class Engage: Dispatchable {
    static var serializer = 0

    internal override func launch_() {
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

        st.nose.color = .red
        st.sprite.color = .white
        if abs(gc.gridPosition.x) == 57 && abs(gc.gridPosition.y) == 54 {
            Log.L.write("Engage \(six(st.name))", level: 52)
        }
        gc.lock(require: false, ownerName: st.name) { ch.engagerKey = $0 }
        st.nose.color = .green

        if ch.engagerKey is ColdKey {
            st.nose.color = .blue
            Log.L.write("Reschedule \(six(st.name)) for \(gc)", level: 59)
            gc.reschedule(st)
            return
        }

        st.nose.color = .cyan

        Log.L.write("Hot key \(six(st.name)) at \(ch.engagerKey!.gridPosition)", level: 56)
        ch.worldStats = World.stats.copy()
        precondition(ch.engagerKey?.sprite?.getStepper(require: false) != nil)
        precondition(
            (ch.engagerKey == nil  ||
                (ch.engagerKey?.sprite?.getStepper(require: false)?.name == st.name &&
                ch.engagerKey?.gridPosition == st.gridCell.gridPosition &&
                ch.engagerKey?.sprite?.getStepper(require: false)?.gridCell.gridPosition == st.gridCell.gridPosition)
        ))
        dp.funge()
        st.nose.color = .magenta
    }
}
