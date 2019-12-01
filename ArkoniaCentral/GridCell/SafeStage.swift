class SafeStage: SafeConnectorProtocol {
    let willMove: Bool
    let fromCell: SafeCell?
    var fromCellForCommit: SafeCell?
    let toCell: SafeCell
    var toCellForCommit: SafeCell?

    init(_ from: SafeCell?, _ to: SafeCell) {
        self.fromCell = from; self.toCell = to; willMove = (from != nil)
    }

    deinit {
        guard fromCellForCommit == nil && toCellForCommit == nil else {
            commit()
            return
        }
    }

    func commit() {
        guard let t = toCellForCommit else { fatalError() }

        if fromCellForCommit != nil {
            let newFrom = GridCell.at(fromCellForCommit!)
            newFrom.contents = fromCellForCommit!.contents
            newFrom.sprite = fromCellForCommit!.sprite
            newFrom.ownerName = fromCellForCommit!.parasite ?? fromCellForCommit!.ownerSignature
        }

        let newTo = GridCell.at(t)
        newTo.contents = t.contents
        newTo.sprite = t.sprite

        fromCellForCommit = nil
        toCellForCommit = nil
    }

    func move() {
        if !willMove { return }

        if let f = fromCell {
            fromCellForCommit = SafeCell(from: f, newContents: .nothing, newSprite: nil, takeOwnership: false)
            toCellForCommit = SafeCell(from: toCell, newContents: f.contents, newSprite: f.sprite, takeOwnership: false)
            return
        }

        toCellForCommit = SafeCell(from: toCell, takeOwnership: false)
    }
}
