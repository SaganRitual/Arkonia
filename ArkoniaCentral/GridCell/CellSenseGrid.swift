class CellSenseGrid: CustomDebugStringConvertible {
    var cells = [GridCellKey]()
    var centerName = ""
    var debugDescription = ""

    init(from center: HotKey, by cGridlets: Int, block: AKPoint) {

        guard let cc = center.getCell() else { preconditionFailure() }
        centerName = cc.ownerName

        precondition(cc.sprite?.getStepper(require: false) != nil)

        debugDescription += "center \(six(centerName)) at \(cc.gridPosition); "

        cells = [center] + (1..<cGridlets).map { index in
            guard let position = center.getCell()?.getGridPointByIndex(index)
                else { preconditionFailure() }

            if position == block { debugDescription += ".."; return NilKey() }
            guard let cell = GridCell.atIf(position) else { debugDescription += "^^"; return NilKey() }
            if index > ArkoniaCentral.cMotorGridlets { debugDescription += "Cx"; return ColdKey(for: cell) }

            precondition(GridCell.at(position).ownerName != centerName)

            var gotlock: GridCellKey?
            cell.lock(require: false, ownerName: centerName) { gotlock = $0 }

            let debugContents: String = {
                switch gotlock?.contents {
                case .invalid: return "i"
                case .arkon:   return ((gotlock is HotKey) ? "a" : "c") + "\(cell.ownerName) at \(cell.gridPosition)"
                case .manna:   return "m"
                case .nothing: return "n"
                case nil:      return "L"
                }
            }()
            debugDescription += "H" + debugContents

            return gotlock!
        }

        cc.sprite?.getStepper()?.dispatch.scratch.debugReport.append(debugDescription)
        Log.L.write("SenseGrid for \(six(centerName)): \(self)", level: 55)
    }

    deinit {
        Log.L.write("~SenseGrid for \(six(centerName))", level: 51)
    }
}
