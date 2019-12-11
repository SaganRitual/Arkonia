class CellSenseGrid {
    var cells = [GridCellKey]()
    var centerName = ""

    init(from center: HotKey, by cGridlets: Int, block: AKPoint) {

        guard let cc = center.cell else { preconditionFailure() }
        centerName = cc.ownerName

        cells = [center] + (1..<cGridlets).map { index in
            guard let position = center.cell?.getGridPointByIndex(index)
                else { preconditionFailure() }

            if position == block { return NilKey() }
            guard let cell = GridCell.atIf(position) else { return NilKey() }
            if index > ArkoniaCentral.cMotorGridlets { return ColdKey(for: cell) }

            var gotlock: GridCellKey?
            cell.lock(require: false, ownerName: centerName) { gotlock = $0 }

            if let c = gotlock?.cell, let d = center.cell  {
                c.ownerName = d.ownerName
            }

            return gotlock!
        }
    }

    deinit {
        Log.L.write("~SenseGrid for \(six(centerName))", level: 42)
    }
}
