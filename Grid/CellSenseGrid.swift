class CellSenseGrid: CustomDebugStringConvertible {
    var cells = [GridCellKey]()
    var centerName = ""
    var debugDescription = ""

    init(from center: HotKey, by cGridlets: Int, block: AKPoint) {
        guard let cc = center.bell else { fatalError() }
        centerName = cc.ownerName

        cells = [center] + (1..<cGridlets).map { index in
            guard let position = center.bell?.getGridPointByIndex(index)
                else { fatalError() }

            if position == block { return NilKey() }
            guard let cell = GridCell.atIf(position) else { return NilKey() }
            if index > Arkonia.cMotorGridlets { return cell.coldKey! }

            let lockType: GridCell.RequireLock = index > Arkonia.cMotorGridlets ? .cold : .degradeToCold

            guard let lock = cell.lock(require: lockType, ownerName: centerName)
                else { fatalError() }

            return lock
        }
    }

//    deinit {
//        cells.dropFirst().compactMap({ $0 as? HotKey }).forEach { $0.releaseLock() }
//    }

    func getRandomHotKey() -> HotKey? {
        return cells.dropFirst().compactMap({ $0 as? HotKey }).randomElement()
    }
}
