class SafeSenseGrid: SafeConnectorProtocol {
    let cells: [SafeCell?]

    init(from center: SafeCell, by cGridlets: Int) {
        cells = [center] + (1..<cGridlets).map {
            let position = center.getGridPointByIndex($0, absolute: true)

            guard let unsafeCell = GridCell.atIf(position) else { return nil }
            return SafeCell(from: unsafeCell, ownerSignature: center.ownerSignature)
        }
    }

    deinit {
        let center = cells[0]?.gridPosition
        let ownerName = cells[0]?.parasite ?? cells[0]?.ownerSignature
        Log.L.write("~SafeSenseGrid centered at \(center!) for \(six(ownerName)) previous \(six(cells[0]?.ownerSignature))")
    }
}
