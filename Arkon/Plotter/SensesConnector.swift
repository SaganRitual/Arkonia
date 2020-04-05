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
    var firstNonGridInput = 0

    init(_ scratch: Scratchpad) { self.scratch = scratch }

    deinit {
        Debug.log(level: 147) { "SensesConnector deinit \(six(scratch?.name))" }
    }

    func connect(_ onComplete: @escaping () -> Void) {
        guard let (ch, _, _) = scratch?.getKeypoints() else { fatalError() }
        guard let sg = ch.senseGrid else { fatalError() }

        connectGridInputs(from: sg) {
            self.connectNonGridInputs()
            onComplete()
        }
    }

    // We create the cell sense grid anew each time the arkon moves, so we
    // can't connect directly to the sense inputs as we do with the non-grid inputs
    private func connectGridInputs(
        from senseGrid: CellSenseGrid, _ onComplete: @escaping () -> Void
    ) {
        func b() { Grid.arkonsPlaneQueue.async(execute: c) }

        func c() {
            guard let (ch, _, _) = scratch?.getKeypoints() else { fatalError() }

            let scale = 1.0 / ch.currentEntropyPerJoule
            Debug.log(level: 154) { "scale = \(scale) = 1 / \(ch.currentEntropyPerJoule) " }

            if ch.gridInputs.isEmpty { ch.gridInputs = [Double](repeating: 0, count: Arkonia.cSenseNeuronsSpatial + Arkonia.cSenseNeuronsNonSpatial) }
//            ch.gridInputs.removeAll(keepingCapacity: true)

            (0..<senseGrid.cells.count).forEach { ss in
                ch.gridInputs[2 * ss + 0] = self.loadNutrition(senseGrid.cells[ss])
                ch.gridInputs[2 * ss + 1] = self.loadSelector(senseGrid.cells[ss])
            }

            firstNonGridInput = senseGrid.cells.count * 2

            Dispatch.dispatchQueue.async(execute: onComplete)
        }

        b()
    }

    // We need connect only once to the non-grid inputs, so we take care of
    // that in the initializer
    private func connectNonGridInputs() {
        guard let (ch, _, st) = scratch?.getKeypoints() else { fatalError() }

        ch.gridInputs[firstNonGridInput + 0] = Double(st.gridCell.gridPosition.x) / Double(Grid.shared!.wGrid)
        ch.gridInputs[firstNonGridInput + 1] = Double(st.gridCell.gridPosition.y) / Double(Grid.shared!.hGrid)
        ch.gridInputs[firstNonGridInput + 2] = Double(st.metabolism.hunger)
        ch.gridInputs[firstNonGridInput + 3] = Double(st.metabolism.co2Level) / Double(Arkonia.co2MaxLevel)

        for (ss, pollenator) in zip(0..., MannaCannon.shared!.pollenators) {
            let diff = st.sprite.position - pollenator.node.position

            let t = (diff.x == 0) ? 0 : atan(Double(diff.y) / Double(diff.x))
            let tt = t / (Double.pi / 2)

//            Debug.log { "\(radius.load()), \(theta.load()), \(t), \(tt)" }
//            Debug.histogrize(theta.load(), scale: 10, inputRange: -1..<1)

            ch.gridInputs[firstNonGridInput + 4 + ss * 2 + 0] = Double(diff.hypotenuse / Grid.shared.hypoteneuse)
            ch.gridInputs[firstNonGridInput + 4 + ss * 2 + 1] = tt
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
