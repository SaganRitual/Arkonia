struct GridArkons {
    func arkonAt(_ absoluteIndex: Int) -> Stepper? {
        guard let a = Grid.cellAt(absoluteIndex).contents.arkon else { return nil }

        // If there's an adult there, it had better be an adult; cells with
        // embryos shouldn't be visible from here
        return (a as? Stepper)!
    }

    func detachArkonFromGrid(at absoluteIndex: Int) {
        // This is the only strong reference to the arkon; should destruct now
        Grid.cellAt(absoluteIndex).contents.arkon = nil
    }

    func moveArkon(from absoluteIndex: Int, toGridCell: GridCell) {
        let fromGridCell = Grid.cellAt(absoluteIndex)
        toGridCell.contents.arkon = fromGridCell.contents.arkon
        fromGridCell.contents.arkon = nil
    }

    func placeNewborn(_ newborn: Stepper, at absoluteIndex: Int) {
        let cell = Grid.cellAt(absoluteIndex)
        cell.contents.arkon = newborn
    }
}
