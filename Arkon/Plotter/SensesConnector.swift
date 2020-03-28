import CoreGraphics

struct SensoryInput {
    let activator: ((Double) -> (Double))?
    let getRawValue: () -> Double
    let scale: Double

    init(
        scale: Double,
        _ getRawValue: @escaping () -> Double,
        _ activator: ((Double) -> Double)?
    ) {
        self.activator = activator
        self.getRawValue = getRawValue
        self.scale = scale
    }

    func load() -> Double {
        let scaled = getRawValue() / scale
        let activated = activator?(scaled) ?? scaled
        return activated
    }
}

class SensesConnector {
    weak var scratch: Scratchpad?
    private(set) var gridInputs = [SensoryInput]()
    private(set) var nonGridInputs = [SensoryInput]()

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

        func b() { Grid.serialQueue.async(execute: c) }

        func c() {
            let scale = 1.0 / entropyPerJoule
            Debug.log(level: 154) { "scale = \(scale) = 1 / \(entropyPerJoule) " }

            gridInputs = senseGrid.cells.map { cell in
                SensoryInput(
                    scale: scale,
                    { [weak self] in self!.loadGridInput(cell) },
                    { scaledValue in max(0, scaledValue) }
                )
            }

            onComplete()
        }

        a()
    }

    static let cBuckets = 10
    static var histogram = [Int](repeating: 0, count: cBuckets)
    static var histoQueue = DispatchQueue.global(qos: .utility)
    static func histogrize(_ value: Double) {
        histoQueue.async {
            precondition(value >= -1.0 && value <= 1.0)

            let vv = (value < 1.0) ? value : value - 1e4    // Because we do get 1.0 sometimes
            let ss = Int((vv + 1) * Double(cBuckets / 2))
            histogram[ss] += 1
            Debug.log(level: 155) { "H: \(histogram)" }
        }
    }

    // We need connect only once to the non-grid inputs, so we take care of
    // that in the initializer
    private func connectNonGridInputs() {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        let myX = SensoryInput(
            scale: Double(Grid.shared!.wGrid),
            { Double(st.gridCell.gridPosition.x) },
            { $0 }  // identity function, we're already scaled to -1..<1
        )

        let myY = SensoryInput(
            scale: Double(Grid.shared!.hGrid),
            { Double(st.gridCell.gridPosition.y) },
            { $0 }  // identity function, we're already scaled to -1..<1
        )

        let hunger = SensoryInput(scale: 1, { Double(st.metabolism.hunger) }, { $0 })
        let asphyxia = SensoryInput(scale: Double(Arkonia.co2MaxLevel), { Double(st.metabolism.co2Level) }, { $0 })

        nonGridInputs.append(myX)
        nonGridInputs.append(myY)
        nonGridInputs.append(hunger)
        nonGridInputs.append(asphyxia)

        for fertileSpot in MannaCannon.shared!.fertileSpots {
            let diff = st.sprite.position - fertileSpot.node.position

            let radius = SensoryInput(
                scale: Double(Grid.shared.hypoteneuse),
                { Double(diff.hypotenuse) }, { $0 }
            )

            let theta = SensoryInput(
                scale: Double.pi / 2,
                { (diff.x == 0) ? 0 : atan(Double(diff.y) / Double(diff.x)) }, { Double($0) }
            )

            nonGridInputs.append(radius)
            nonGridInputs.append(theta)
        }
    }

    private func loadGridInput(_ cellKey: GridCellKey) -> Double {
        switch cellKey.contents {
        case .arkon:   return 0
        case .invalid: return 0
        case .nothing: break
        }

        guard let manna = cellKey.mannaSprite?.getManna(require: false) else { return 0 }

        let energy = Double(manna.getEnergyContentInJoules() / Arkonia.maxMannaEnergyContentInJoules)
        Debug.log(level: 154) { "load grid input \(energy)" }

        // If the manna is fully charged, we can get a 1.0 out of the
        // scaling above. Shave a bit off it so we don't go outside our
        // array boundaries later in the signal-driving process
        return (energy < 1.0) ? energy : energy - 1e-4
    }
}
