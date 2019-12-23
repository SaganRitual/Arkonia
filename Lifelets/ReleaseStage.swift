import Dispatch

final class ReleaseStage: Dispatchable {
    internal override func launch() {
        var barf = false
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        guard let shuttle = ch.cellShuttle else { preconditionFailure() }
        guard let toCell = shuttle.toCell else { preconditionFailure() }
        writeDebug("ReleaseStage \(six(st.name))", scratch: ch)

        Debug.debugColor(st, .green, .cyan)

        precondition(
            ((ch.engagerKey == nil && ch.cellShuttle != nil) || (ch.engagerKey != nil &&
                ch.engagerKey?.sprite?.getStepper(require: false)?.name == st.name &&
                ch.engagerKey?.gridPosition == st.gridCell.gridPosition &&
                ch.engagerKey?.sprite?.getStepper(require: false)?.gridCell.gridPosition == st.gridCell.gridPosition)
        ))

        if ch.engagerKey?.ownerName == "barf" { barf = true }

//        var report = ""
//        if let f = shuttle.fromCell { report += "from \(six(f.ownerName)) at \(f.gridPosition)\n" }
//        if let t = shuttle.toCell { report += "to   \(six(t.ownerName)) at \(t.gridPosition)\n" }
//        if let e = ch.engagerKey { report += "eng  \(six(e.ownerName))(\(e is HotKey)) at \(e.gridPosition)" }
//        if report.isEmpty == false {
//            let rs = "ReleaseStage\n"
//            Log.L.write("\(rs)\(report)", level: 55)
//        }

        let chengagerKey = ch.engagerKey, shuttlefromcell = shuttle.fromCell, shuttletocell = shuttle.toCell, chcellshuttle = ch.cellShuttle

        if barf {
            print(chengagerKey!, shuttlefromcell!, shuttletocell!, chcellshuttle!)
        }

        ch.engagerKey = toCell
        shuttle.fromCell = nil
        shuttle.toCell = nil
        ch.cellShuttle = nil

        precondition(
            (ch.engagerKey == nil  ||
                (ch.engagerKey?.sprite?.getStepper(require: false)?.name == st.name &&
                ch.engagerKey?.gridPosition == st.gridCell.gridPosition &&
                ch.engagerKey?.sprite?.getStepper(require: false)?.gridCell.gridPosition == st.gridCell.gridPosition)
        ))
        dp.metabolize()
    }
}
