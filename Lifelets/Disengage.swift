import Dispatch

final class Disengage: Dispatchable {
    internal override func launch() {
        precondition(scratch?.name != nil)
        precondition(scratch?.name == scratch?.stepper?.name)
        precondition(scratch?.stepper?.name == ((scratch?.stepper?.sprite.getStepper(require: false))?.sprite?.name))
        guard let (ch, dp, st) = self.scratch?.getKeypoints() else { fatalError() }
        debugColor(st, .cyan, .cyan)
        writeDebug("Disengage \(six(st.name))", scratch: ch)

        Log.L.write("Reset engagerKey #0", level: 41)

        precondition(ch.cellShuttle == nil && ch.engagerKey != nil)

        ch.engagerKey = nil
        dp.engage()
    }

}
