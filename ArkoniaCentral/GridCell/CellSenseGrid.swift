class CellSenseGrid {
    var cells = [GridCellKey]()
    var centerName = ""

    init(from center: HotKey, by cGridlets: Int, block: AKPoint) {

        centerName = center.cell.ownerName

        cells = [center] + (1..<cGridlets).map { index in
            let position = center.cell.getGridPointByIndex(index)

            if position == block { return NilKey() }
            guard let cell = GridCell.atIf(position) else { return NilKey() }
            if index > ArkoniaCentral.cMotorGridlets { return ColdKey(for: cell) }

            let gotlock = cell.lock(require: false)
            if let g = gotlock as? HotKey {
                g.cell.ownerName = center.cell.ownerName
            }
            Log.L.write("SenseGrid for \(six(centerName))/\(six((gotlock as? HotKey)?.cell.ownerName)) cell \(position), gotlock = \(gotlock is HotKey), owner = \(six(gotlock.ownerName))", level: 42)
            return gotlock
        }

//        for cell in cells {
//            Log.L.write("cell held by \(six(centerName)) at \((cell as? HotKey)?.cell ?? GridCell.at(0, 0)) is \(cell)", level: 41)
//        }
    }

    deinit {
        Log.L.write("~SenseGrid for \(six(centerName))", level: 42)
    }
}
