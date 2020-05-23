import CoreGraphics

struct GridInput {
    let loadSelector: () -> Double
    let loadNutrition: () -> Double

    init(_ loadNutrition: @escaping () -> Double, _ loadSelector: @escaping () -> Double) {
        self.loadNutrition = loadNutrition
        self.loadSelector = loadSelector
    }
}

struct NonGridInput {
    let load: () -> Double

    init(_ load: @escaping () -> Double) { self.load = load }
}

class SensesConnector {
    weak var scratch: Scratchpad!
    var firstNonGridInput = 0

    init(_ scratch: Scratchpad) { self.scratch = scratch }

    deinit {
        Debug.log(level: 147) { "SensesConnector deinit \(six(scratch?.name))" }
    }

    func connect(_ onComplete: @escaping () -> Void) {
        let sg = (scratch.senseGrid)!
        var yearFullness = CGFloat.zero
        var dayFullness = CGFloat.zero

        func a() {
            Seasons.shared.getSeasonalFactors {
                dayFullness = $0; yearFullness = $1; b()
            }
        }

        func b() { connectGridInputs(from: sg, c) }
        func c() { connectNonGridInputs(dayFullness, yearFullness); onComplete() }

        a()
    }

    // We create the cell sense grid anew each time the arkon moves, so we
    // can't connect directly to the sense inputs as we do with the non-grid inputs
    private func connectGridInputs(
        from senseGrid: SenseGrid, _ onComplete: @escaping () -> Void
    ) {
        func b() { Grid.arkonsPlaneQueue.async(execute: c) }

        func c() {
            let scale = 1.0 / scratch.currentEntropyPerJoule
            Debug.log(level: 154) { "scale = \(scale) = 1 / \(scratch.currentEntropyPerJoule) " }

            if scratch.gridInputs.isEmpty {
                scratch.gridInputs = [Double](repeating: 0, count: Arkonia.cSenseNeurons)
            }

            for ss in 0..<senseGrid.cells.count {
                guard let cell = senseGrid.cells[ss] as? GridCell else { continue }
                scratch.gridInputs[2 * ss + 0] = self.loadNutrition(cell)
                scratch.gridInputs[2 * ss + 1] = self.loadSelector(cell)
            }

            firstNonGridInput = senseGrid.cells.count * 2

            Dispatch.dispatchQueue.async(execute: onComplete)
        }

        b()
    }

    // We need connect only once to the non-grid inputs, so we take care of
    // that in the initializer
    private func connectNonGridInputs(_ dayFullness: CGFloat, _ yearFullness: CGFloat) {
        func miscSense(_ sense: Arkonia.MiscSense) -> Int { firstNonGridInput + sense.rawValue  }
        func pollenatorSense(_ index: Int) -> Int { firstNonGridInput + Arkonia.cSenseNeuronsMisc + index * 2  }

        let st = scratch.stepper!, gc = st.gridCell!, mt = st.metabolism!, cs = mt.spawn

        // Average fullness of the spawn embryo; not really very representative,
        // see whether it has any effect.
        let ff = cs?.fatStore?.fullness ?? 0
        let hf = cs?.hamStore.fullness ?? 0
        let of = cs?.oxygenStore.fullness ?? 0
        let gestationFullness = (ff + hf + of) / 3.0

        scratch.gridInputs[miscSense(.y)] = Double(gc.gridPosition.y) / Double(Grid.shared!.gridHeightInCells)
        scratch.gridInputs[miscSense(.hunger)] = Double(mt.hunger)
        scratch.gridInputs[miscSense(.asphyxiation)] = Double(mt.asphyxiation)
        scratch.gridInputs[miscSense(.gestationFullness)] = Double(gestationFullness)
        scratch.gridInputs[miscSense(.dayFullness)] = Double(dayFullness)
        scratch.gridInputs[miscSense(.yearFullness)] = Double(yearFullness)

        for pollenator in MannaCannon.shared!.pollenators {
            let diff = scratch.stepper.sprite.position - pollenator.node.position

            let t = (diff.x == 0) ? 0 : atan(Double(diff.y) / Double(diff.x))
            let tt = t / (Double.pi / 2)

//            Debug.log { "\(radius.load()), \(theta.load()), \(t), \(tt)" }
//            Debug.histogrize(theta.load(), scale: 10, inputRange: -1..<1)

            scratch.gridInputs[pollenatorSense(0)] = Double(diff.hypotenuse / Grid.shared.hypoteneuse)
            scratch.gridInputs[pollenatorSense(1)] = tt
        }
    }

    enum CellContents: Double {
        case invalid = 0, arkon = 1, empty = 2, manna = 3

        func asSenseData() -> Double { return self.rawValue / 4.0 }
    }

    private func loadSelector(_ cellKey: GridCellProtocol) -> Double {
        let contents: CellContents

        if cellKey is NilKey           { contents = .invalid } // Off the grid
        else if cellKey.stepper != nil { contents = .arkon }
        else if cellKey.manna == nil   { contents = .empty }
        else                           { contents = .manna }

        return contents.asSenseData()
    }

    private func loadNutrition(_ cellKey: GridCellProtocol) -> Double {
        if cellKey is NilKey { return 0 }

        // Seems like we need to separate the different cell types here
        if cellKey.stepper != nil { return 0 }
        guard let manna = cellKey.manna else { return 0 }

        let energy = Double(manna.sprite.getMaturityLevel())
        Debug.log(level: 154) { "load grid input \(energy)" }

        // If the manna is fully charged, we can get a 1.0 out of the
        // scaling above. Shave a bit off it so we don't go outside our
        // array boundaries later in the signal-driving process
        return (energy < 1.0) ? energy : energy - 1e-4
    }
}
