class CellSenseGrid {
    let cells: [GridCellKey]

    init(from center: HotKey, by cGridlets: Int) {
        cells = [center] + (1..<cGridlets).map {
            let position = center.cell.getGridPointByIndex($0, absolute: true)

            guard let cell = GridCell.atIf(position) else { return NilKey() }

            return cell.lock(require: false)
        }

        for cell in cells {
            Log.L.write("cell at \((cell as? HotKey)?.cell ?? GridCell.at(0, 0)) is \(cell)", level: 32)
        }
    }
}
