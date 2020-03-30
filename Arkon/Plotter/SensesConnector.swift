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
    weak var scratch: Scratchpad?
    private(set) var gridInputs = [GridInput]()
    private(set) var nonGridInputs = [NonGridInput]()

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        connectNonGridInputs()
    }

    deinit {
        Debug.log(level: 147) { "SensesConnector deinit \(six(scratch?.name))" }
    }

    // We create the cell sense grid anew each time the arkon moves, so we
    // can't connect directly to the sense inputs as we do with the non-grid inputs
    func connectGridInputs(
        from senseGrid: CellSenseGrid, _ onComplete: @escaping () -> Void
    ) {
        var entropyPerJoule = 0.0
        func a() { Clock.shared.entropize(1) { entropyPerJoule = Double($0); b() } }

        func b() { Grid.arkonsPlaneQueue.async(execute: c) }

        func c() {
            let scale = 1.0 / entropyPerJoule
            Debug.log(level: 154) { "scale = \(scale) = 1 / \(entropyPerJoule) " }

            gridInputs = senseGrid.cells.map { cell in
                GridInput(
                    { [weak self] in self!.loadNutrition(cell) },
                    { [weak self] in self!.loadSelector(cell) }
                )
            }

            Dispatch.dispatchQueue.async(execute: onComplete)
        }

        a()
    }

    // We need connect only once to the non-grid inputs, so we take care of
    // that in the initializer
    private func connectNonGridInputs() {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        let myX = NonGridInput(
            { Double(st.gridCell.gridPosition.x) / Double(Grid.shared!.wGrid) }
        )

        let myY = NonGridInput(
            { Double(st.gridCell.gridPosition.y) / Double(Grid.shared!.hGrid) }
        )

        let hunger = NonGridInput({ Double(st.metabolism.hunger)})
        let asphyxia = NonGridInput(
            { Double(st.metabolism.co2Level) / Double(Arkonia.co2MaxLevel) }
        )

        nonGridInputs.append(myX)
        nonGridInputs.append(myY)
        nonGridInputs.append(hunger)
        nonGridInputs.append(asphyxia)

        for pollenator in MannaCannon.shared!.pollenators {
            let diff = st.sprite.position - pollenator.node.position

            let radius = NonGridInput(
                { Double(diff.hypotenuse / Grid.shared.hypoteneuse) }
            )

            let t = (diff.x == 0) ? 0 : atan(Double(diff.y) / Double(diff.x))
            let tt = t / (Double.pi / 2)
            let theta = NonGridInput({ tt })

//            Debug.log { "\(radius.load()), \(theta.load()), \(t), \(tt)" }
//            Debug.histogrize(theta.load(), scale: 10, inputRange: -1..<1)

            nonGridInputs.append(radius)
            nonGridInputs.append(theta)
        }
    }

    enum CellContents: Double {
        case invalid = 0, arkon = 1, empty = 2, manna = 3

        func asSenseData() -> Double { return self.rawValue / 4.0 }
    }

    private func loadSelector(_ cellKey: GridCellKey) -> Double {
        let contents: CellContents

        if cellKey is NilKey           { contents = .invalid } // Off the grid
        else if cellKey.stepper != nil { contents = .arkon }
        else if cellKey.manna == nil   { contents = .empty }
        else                           { contents = .manna }

        return contents.asSenseData()
    }

    private func loadNutrition(_ cellKey: GridCellKey) -> Double {
        if cellKey is NilKey { return 0 }

        // Seems like we need to separate the different cell types here
        if cellKey.stepper != nil { return 0 }
        guard let manna = cellKey.manna else { return 0 }

        let energy = Double(manna.getEnergyContentInJoules() / Arkonia.maxMannaEnergyContentInJoules)
        Debug.log(level: 154) { "load grid input \(energy)" }

        // If the manna is fully charged, we can get a 1.0 out of the
        // scaling above. Shave a bit off it so we don't go outside our
        // array boundaries later in the signal-driving process
        return (energy < 1.0) ? energy : energy - 1e-4
    }
}
