extension Shifter {
    func loadGridInputs() {
        guard let scr = scratch else { fatalError() }
        guard let gcc = scr.gridCellConnector as? SafeSenseGrid else {
            fatalError()
        }

//        print("loadGridInputs \(six(scr.stepper!.name))")
        sensoryInputs = gcc.cells.map { self.loadGridInput_($0) }
        Grid.shared.concurrentQueue.async(execute: calculateShift)
    }

    func reserveGridPoints() {
//        print("reserveGridPoints entry")
        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }
//        print("reserveGridPoints entry \(six(st.name))")
        guard let oldGcc = scr.gridCellConnector as? SafeCell else {
            fatalError()
        }

        assert(oldGcc.owner != nil)
//        print("reserveGridPoints pre extend \(six(st.name))")

        let wiReserveGridPoints = st.gridCell.extend(
            owner: st.name,
            from: oldGcc,
            by: ArkoniaCentral.cMotorGridlets,

            onLock: { newGcc in
//                print("reserveGridPoints post extend \(six(st.name))")
                scr.gridCellConnector = newGcc
                if (scr.gridCellConnector as? SafeSenseGrid) == nil { fatalError() }
                self.loadGridInputs()
            }
        )

//        print("reserveGridPoints start extend \(six(st.name))")
        Grid.shared.concurrentQueue.async(flags: .barrier) {
            wiReserveGridPoints.perform()
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
