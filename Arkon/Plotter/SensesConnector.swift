import CoreGraphics

struct SensoryInput {
    let getRawValueDouble: (() -> Double)?
    let getRawValueCGFloat: (() -> CGFloat)?
    let scale: Double

    init(scale: Double, _ getRawValue: @escaping () -> Double) {
        self.scale = scale
        self.getRawValueDouble = getRawValue
        self.getRawValueCGFloat = nil
    }

    init(scale: CGFloat, _ getRawValue: @escaping () -> CGFloat) {
        self.scale = Double(scale)
        self.getRawValueCGFloat = getRawValue
        self.getRawValueDouble = nil
    }

    func load() -> Double {
        if let rv = getRawValueDouble { return rv() / scale }
        return (Double)(getRawValueCGFloat!()) / scale
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
            let scale = Double(Arkonia.maxMannaEnergyContentInJoules) / entropyPerJoule
            Debug.log(level: 145) { "scale = \(scale) = \(entropyPerJoule) / \(Arkonia.maxMannaEnergyContentInJoules) " }

            gridInputs = senseGrid.cells.map { cell in
                SensoryInput(scale: scale) { [weak self] in self!.loadGridInput(cell) }
            }

            onComplete()
        }

        a()
    }

    // We need connect only once to the non-grid inputs, so we take care of
    // that in the initializer
    private func connectNonGridInputs() {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        let myX = SensoryInput(
            scale: GriddleScene.arkonsPortal.size.width,
            { st.gridCell.scenePosition.x }
        )

        let myY = SensoryInput(
            scale: GriddleScene.arkonsPortal.size.height,
            { st.gridCell.scenePosition.y }
        )

        let hunger = SensoryInput(scale: 1) { st.metabolism.hunger }
        let asphyxia = SensoryInput(scale: Arkonia.co2MaxLevel) { st.metabolism.co2Level }

        nonGridInputs.append(myX)
        nonGridInputs.append(myY)
        nonGridInputs.append(hunger)
        nonGridInputs.append(asphyxia)

        for fertileSpot in MannaCannon.shared!.fertileSpots {
            let diff = st.sprite.position - fertileSpot.node.position

            let radius = SensoryInput(
                scale: GriddleScene.arkonsPortal.size.hypotenuse / 2,
                { diff.hypotenuse / 2 }
            )

            let theta = SensoryInput(
                scale: CGFloat.pi / 2,
                { (diff.x == 0) ? 0 : atan(diff.y / diff.x) }
            )

            nonGridInputs.append(radius)
            nonGridInputs.append(theta)
        }
    }

    private func loadGridInput(_ cellKey: GridCellKey) -> Double {
        switch cellKey.contents {
        case .arkon:   return 0
        case .nothing: return 0
        case .invalid: return 0

        case .manna:
            guard let manna = cellKey.sprite?.getManna(require: false)
                else { fatalError() }

            Debug.log(level: 145) { "load grid input \(manna.getEnergyContentInJoules())" }
            return Double(manna.getEnergyContentInJoules())
        }
    }
}
