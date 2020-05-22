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
            let scale = 1.0 / scratch.currentEntropyPerJoule
            Debug.log(level: 154) { "scale = \(scale) = 1 / \(scratch.currentEntropyPerJoule) " }

            if scratch.gridInputs.isEmpty { scratch.gridInputs = [Double](repeating: 0, count: Arkonia.cSenseNeuronsSpatial + Arkonia.cSenseNeuronsNonSpatial) }
//            scratch.gridInputs.removeAll(keepingCapacity: true)

            (0..<senseGrid.cells.count).forEach { ss in
                scratch.gridInputs[2 * ss + 0] = self.loadNutrition(senseGrid.cells[ss])
                scratch.gridInputs[2 * ss + 1] = self.loadSelector(senseGrid.cells[ss])
            }

            firstNonGridInput = senseGrid.cells.count * 2

            Dispatch.dispatchQueue.async(execute: onComplete)
        }

        b()
    }

    // We need connect only once to the non-grid inputs, so we take care of
    // that in the initializer
    private func connectNonGridInputs() {
        scratch.gridInputs[firstNonGridInput + 0] = Double(scratch.stepper.gridCell.gridPosition.x) / Double(Grid.shared!.gridWidthInCells)
        scratch.gridInputs[firstNonGridInput + 1] = Double(scratch.stepper.gridCell.gridPosition.y) / Double(Grid.shared!.gridHeightInCells)
        scratch.gridInputs[firstNonGridInput + 2] = Double(scratch.stepper.metabolism.hunger)
        scratch.gridInputs[firstNonGridInput + 3] = Double(scratch.stepper.metabolism.asphyxiation)

        for (ss, pollenator) in zip(0..., MannaCannon.shared!.pollenators) { autoreleasepool {
            let diff = scratch.stepper.sprite.position - pollenator.node.position

            let t = (diff.x == 0) ? 0 : atan(Double(diff.y) / Double(diff.x))
            let tt = t / (Double.pi / 2)

//            Debug.log { "\(radius.load()), \(theta.load()), \(t), \(tt)" }
//            Debug.histogrize(theta.load(), scale: 10, inputRange: -1..<1)

            scratch.gridInputs[firstNonGridInput + 4 + ss * 2 + 0] = Double(diff.hypotenuse / Grid.shared.hypoteneuse)
            scratch.gridInputs[firstNonGridInput + 4 + ss * 2 + 1] = tt
        }}
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
