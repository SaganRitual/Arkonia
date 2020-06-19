extension SensorPad {
    enum CellContents: Float {
        case invisible = 0, arkon = 1, empty = 2, manna = 3

        func asSenseData() -> Float { return self.rawValue / 4.0 }
    }

    func getContents(in absoluteIndex: Int) -> CellContents {
        if Grid.shared.arkonAt(absoluteIndex) != nil { return .arkon }
        else if Grid.shared.mannaAt(absoluteIndex) != nil { return .manna }

        return .empty
    }

    func getContents(in cell: GridCell) -> CellContents {
        return getContents(in: cell.absoluteIndex)
    }
}
