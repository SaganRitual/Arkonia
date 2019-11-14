extension Shifter {
    func loadGridInputs() {
        guard let gcc = dispatch.gridCellConnector as? SafeSenseGrid else {
            fatalError()
        }

        sensoryInputs = gcc.cells.map { self.loadGridInput_($0) }
    }

    func reserveGridPoints() {
        guard let oldGcc = dispatch.gridCellConnector as? SafeCell else {
            fatalError()
        }

        assert(oldGcc.owner != nil)

        guard let newGcc = stepper.gridCell.extend(
            owner: stepper.name,
            from: oldGcc,
            by: ArkoniaCentral.cMotorGridlets
        ) else { fatalError() }

        dispatch.gridCellConnector = newGcc
        if (dispatch.gridCellConnector as? SafeSenseGrid) == nil
            { fatalError() }

//        print("reserveGridPoints exit \(six(oldGcc.owner))")
    }
}

extension Shifter {

    func loadGridInput_(_ c: SafeCell?) -> (Double, Double)? {
        guard let cell = c else { return nil }

        if !GridCell.isOnGrid(cell.gridPosition) { return nil }

        let nutrition: Double

        switch cell.contents {
        case .arkon:
            nutrition = Double(stepper.metabolism.energyFullness)

        case .manna:
            let sprite = cell.sprite!
            guard let manna = Manna.getManna(from: sprite) else { fatalError() }
            nutrition = Double(manna.energyContentInJoules)

        case .nothing:
            nutrition = 0
        }

        return (cell.contents.rawValue, nutrition)
    }
}
