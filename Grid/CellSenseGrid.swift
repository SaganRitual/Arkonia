class CellSenseGrid: CustomDebugStringConvertible {
    var cells = [GridCellKey]()
    var centerName = ""
    var debugDescription = ""

    init(from center: HotKey, by cGridlets: Int, block: AKPoint) {
        guard let cc = center.gridCell else { fatalError() }
        centerName = cc.ownerName

        cells = [center] + (1..<cGridlets).map { index in
            guard let position = center.gridCell?.getGridPointByIndex(index)
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

    func releaseNonStageCells(keep: HotKey) {
        cells.dropFirst().compactMap({ $0 as? HotKey }).filter({ $0 !== keep }).forEach { $0.releaseLock() }
    }

    func getRandomEmptyHotKey() -> HotKey? {
        return cells.dropFirst().compactMap({ $0 as? HotKey }).filter({ $0.stepper == nil }).randomElement()
    }
}
