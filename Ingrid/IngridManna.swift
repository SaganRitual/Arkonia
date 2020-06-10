class IngridManna {
    private var allTheManna: ContiguousArray<Manna?>

    init(_ cCells: Int) {
        allTheManna = .init(repeating: nil, count: cCells)
    }

    func getNutrition(in cell: IngridCell) -> Float? {
        guard let manna = Ingrid.shared.manna.mannaAt(cell.absoluteIndex) else
            { return nil }

        return Float(manna.sprite.getMaturityLevel())
    }

    func mannaAt(_ absoluteIndex: Int) -> Manna? { allTheManna[absoluteIndex] }

    func mannaAt(_ absolutePosition: AKPoint) -> Manna? {
        let ax = Ingrid.absoluteIndex(of: absolutePosition)
        return allTheManna[ax]
    }

    func placeManna(at absoluteIndex: Int) {
        allTheManna[absoluteIndex] = Manna(absoluteIndex)
    }
}
