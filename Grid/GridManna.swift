struct GridManna {
    func getNutrition(in cell: GridCell) -> Float? {
        guard let manna = cell.contents.manna else { return nil }
        return Float(manna.sprite.getMaturityLevel())
    }

    func mannaAt(_ absoluteIndex: Int) -> Manna? { Grid.cellAt(absoluteIndex).contents.manna }

    func plantManna(at absoluteIndex: Int) -> Manna {
        let m = Manna(absoluteIndex)
        Grid.cellAt(absoluteIndex).contents.manna = m
        return m
    }
}
