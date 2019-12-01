extension Shifter {
    func loadGridInputs() {
        guard let scr = scratch else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeSenseGrid else {
            fatalError()
        }

        sensoryInputs = gcc.cells.map { self.loadGridInput_($0) }
        calculateShift()
    }

    func reserveGridPoints() {
        guard let scr = scratch else { fatalError() }
        guard let oldGcc = scr.gridCellConnector as? SafeCell else {
            fatalError()
        }

        assert(oldGcc.owner != nil)

        Grid.shared.concurrentQueue.sync(flags: .barrier) { [unowned self] in
            guard let scr = self.scratch else { fatalError() }

            let sc = SafeSenseGrid(from: oldGcc, by: ArkoniaCentral.cMotorGridlets)
            scr.gridCellConnector = sc

            self.loadGridInputs()
        }
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
