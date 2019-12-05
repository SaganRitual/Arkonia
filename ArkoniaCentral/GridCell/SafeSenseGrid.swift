class SafeSenseGrid: GridConnectorProtocol {
    let cells: [SafeCell?]

    init(from center: SafeCell, by cGridlets: Int) {
        cells = [center] + (1..<cGridlets).map {
            let position = center.getGridPointByIndex($0, absolute: true)

            guard let hotCell = GridCell.atIf(position) else { return nil }
            let lockedCell = hotCell.lock(require: false)

            return SafeCell(from: hotCell, takeOwnership: lockedCell != nil)
        }
    }
}
