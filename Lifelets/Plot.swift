import CoreGraphics
import Dispatch

final class Plot: Dispatchable {
    var senseData: [Double]?
    var senseGrid: CellSenseGrid?

    static let dispatchQueue = DispatchQueue(
        label: "ak.plot.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .default)
    )

    internal override func launch() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log("Plot \(six(st.name))", level: 71)

        var entropy: CGFloat = 0

        func a() { self.makeSenseGrid(b) }
        func b() { self.computeMove(c) }
        func c() { ch.stillCounter += ch.cellShuttle!.didMove ? 0.005 : 0.05; d() }
        func d() { dp.moveSprite() }

        a()
    }

    func makeSenseGrid(_ onComplete: @escaping () -> Void) {
        guard let (ch, _, st) = scratch?.getKeypoints() else { preconditionFailure() }
        guard let hk = ch.engagerKey as? HotKey else { preconditionFailure() }

        CellSenseGrid.makeCellSenseGrid(
            from: hk, by: Arkonia.cSenseGridlets, block: st.previousShiftOffset
        ) {
            self.senseGrid = $0
            onComplete()
        }
    }

    func getSenseData(_ gridInputs: [Double]) {
        let nonSpatial = getNonSpatialSenseData()
        senseData = gridInputs + nonSpatial
    }

    func computeMove(_ onComplete: @escaping () -> Void) {
        guard let (ch, _, _) = scratch?.getKeypoints() else { fatalError() }
        guard let sg = senseGrid else { fatalError() }

        var gridInputs = [Double]()

        func a() { loadGridInputs(from: sg) { gridInputs = $0; b() } }

        func b() {
            self.getSenseData(gridInputs)
            guard let sd = self.senseData else { fatalError() }
            ch.cellShuttle = self.makeCellShuttle(sd, sg)

            onComplete()
        }

        a()
    }
}

extension Plot {
    private func loadGridInputs(
        from senseGrid: CellSenseGrid, _ onComplete: @escaping ([Double]) -> Void
    ) {
        var gridInputs = [Double]()

        func a(_ ix: Int) {
            if ix >= senseGrid.cells.count { onComplete(gridInputs); return }

            self.loadGridInput(senseGrid.cells[ix]) {
                gridInputs.append(contentsOf: [$0, $1])

                a(ix + 1) // This isn't recursing; it's running in a separate work item
            }
        }

        a(0)
    }

    private func loadGridInput(
        _ cellKey: GridCellKey, _ onComplete: @escaping (Double, Double) -> Void
    ) {
        let contentsAsNetSignal = cellKey.contents.asNetSignal
        let nutritionAsNetSignal: (CGFloat) -> Double = { Double($0) - 0.5 }

        if cellKey.contents == .invalid {
            onComplete(contentsAsNetSignal, 0)
            return
        }

        guard let (_, _, st) = scratch?.getKeypoints() else { preconditionFailure() }

        var nutrition: Double = 0

        switch cellKey.contents {
        case .arkon:
            Clock.shared.entropize(st.metabolism!.energyFullness) {
                nutrition = nutritionAsNetSignal($0)
                onComplete(contentsAsNetSignal, nutrition)
            }

        case .manna:
            guard let manna = cellKey.sprite?.getManna(require: false)
                else { fatalError() }

            var nutrition: CGFloat = 0
            var entropized: CGFloat = 0

            func a() { manna.getNutritionInJoules { nutrition = $0; b() } }

            func b() { Clock.shared.entropize(nutrition) { entropized = $0; c() } }

            func c() {
                onComplete(contentsAsNetSignal, nutritionAsNetSignal(nutrition))
            }

            a()

        case .nothing:
            onComplete(contentsAsNetSignal, 0)

        case .invalid: fatalError()
        }
    }

    private func getNonSpatialSenseData() -> [Double] {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        var theData = [Double]()

        let r = st.gridCell.randomScenePosition?.radius ?? 0
        let t = st.gridCell.randomScenePosition?.theta ?? 0
        let ro = (r / Substrate.shared.hypoteneuse) - 0.5
        let to = (t / Substrate.shared.hypoteneuse) - 0.5
        theData.append(contentsOf: [Double(to), Double(ro)])

        let hunger = Double(st.metabolism.hunger)
        let asphyxia = Double(1 - st.metabolism.oxygenLevel)
        let ho = hunger - 0.5
        let ao = asphyxia - 0.5
        theData.append(contentsOf: [ho, ao])

        return theData
    }

    private func makeCellShuttle(_ senseData: [Double], _ senseGrid: CellSenseGrid) -> CellShuttle {
        guard let ch = scratch else { fatalError() }
        guard let st = ch.stepper else { fatalError() }
        guard let net = st.net else { fatalError() }

        let motorOutputs: [(Int, Double)] =
            zip(0..., net.getMotorOutputs(senseData)).map { data in
                let (ss, signal) = data
                let sSignal = String(format: "%-2.6f", signal)
                guard let dSignal = Double(sSignal) else { fatalError() }
                return(ss, dSignal)
        }

        let trimmed = motorOutputs.filter { abs($0.1) < 1.0 && $0.0 != 0 }

        let order = trimmed.sorted { lhs, rhs in
            let labs = abs(lhs.1)
            let rabs = abs(rhs.1)

            return labs > rabs
        }

        Debug.log("order for \(six(st.name)): \(order)", level: 62)

        let targetOffset = order.first { senseGrid.cells[$0.0] is HotKey }

        let fromCell: HotKey?
        let toCell: HotKey

        if targetOffset == nil || targetOffset!.0 == 0 {
            guard let t = senseGrid.cells[0] as? HotKey else { preconditionFailure() }

            toCell = t; fromCell = nil
            Debug.log("toCell at \(t.gridPosition)", level: 55)
        } else {
            guard let t = senseGrid.cells[targetOffset!.0] as? HotKey else { preconditionFailure() }
            guard let f = senseGrid.cells[0] as? HotKey else { preconditionFailure() }

            toCell = t; fromCell = f
            Debug.log("toCell at \(t.gridPosition), fromCell at \(f.gridPosition)", level: 55)
        }

        if targetOffset == nil {
            Debug.log("targetOffset: nil", level: 53)
        } else {
            Debug.log("targetOffset: \(targetOffset!.0)", level: 53)
        }

        return CellShuttle(fromCell, toCell)
    }
}
