class IngridArkons {
    var allTheArkons: ContiguousArray<Stepper?>

    init(_ cCells: Int) {
        allTheArkons = .init(repeating: nil, count: cCells)
    }

    func arkonAt(_ absoluteIndex: Int) -> Stepper? { allTheArkons[absoluteIndex] }

    func arkonAt(_ absolutePosition: AKPoint) -> Stepper? {
        let ax = Ingrid.absoluteIndex(of: absolutePosition)
        return allTheArkons[ax]
    }

    func moveArkon(_ stepper: Stepper, fromIndex: Int, toIndex: Int) {
        allTheArkons[fromIndex] = nil
        allTheArkons[toIndex] = stepper
        stepper.ingridCellAbsoluteIndex = toIndex
    }

    func placeArkon(_ stepper: Stepper, atIndex: Int) { allTheArkons[atIndex] = stepper }
}
