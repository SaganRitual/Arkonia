extension Shifter {
    func loadGridInputs() {
        guard let scr = scratch else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeSenseGrid else {
            fatalError()
        }

        sensoryInputs = gcc.cells.map { self.loadGridInput_($0) }
    }

    func reserveGridPoints() {
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
        guard let oldGcc = scr.gridCellConnector as? SafeCell else {
            fatalError()
        }

        assert(oldGcc.owner != nil)

        guard let newGcc = st.gridCell.extend(
            owner: st.name, from: oldGcc, by: ArkoniaCentral.cMotorGridlets
        ) else { fatalError() }

        scr.gridCellConnector = newGcc
        if (scr.gridCellConnector as? SafeSenseGrid) == nil { fatalError() }
    }
}

extension Shifter {

    func loadGridInput_(_ c: SafeCell?) -> (Double, Double)? {
        guard let cell = c else { return nil }

        if !GridCell.isOnGrid(cell.gridPosition) { return nil }

        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }

        let nutrition: Double

        switch cell.contents {
        case .arkon:
            nutrition = Double(st.metabolism.energyFullness)

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
