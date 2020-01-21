import CoreGraphics
import Dispatch

final class Plot: Dispatchable {
    var senseData: [Double]?

    deinit {
        scratch?.senseGrid = nil
    }

    internal override func launch() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log("Plot \(six(st.name))", level: 82)

        var entropy: CGFloat = 0

        func a() { self.computeMove(b) }
        func b() { Funge.dispatchQueue.async(execute: c) }
        func c() { ch.co2Counter += ch.cellShuttle!.didMove ? 0 : 1; d() }
        func d() { dp.moveSprite() }

        a()
    }

    func getSenseData(_ gridInputs: [Double]) {
        let nonSpatial = getNonSpatialSenseData()
        senseData = gridInputs + nonSpatial
    }

    func computeMove(_ onComplete: @escaping () -> Void) {
        guard let (ch, _, _) = scratch?.getKeypoints() else { fatalError() }
        guard let sg = ch.senseGrid else { fatalError() }

        var gridInputs = [Double]()

        func a() { loadGridInputs(from: sg) { gridInputs = $0; b() } }

        func b() { Net.dispatchQueue.async(execute: c) }

        func c() {
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
        var entropyPerJoule = 0.0
        func a() { Clock.shared.entropize(1) { entropyPerJoule = Double($0); b() } }

        func b() { Substrate.serialQueue.async(execute: c) }

        func c() {
            var gridInputs = [Double]()
            for ix in 0..<senseGrid.cells.count {
                let (content, nutrition) = self.loadGridInput(senseGrid.cells[ix])
                let cc = content * entropyPerJoule, nn = nutrition * entropyPerJoule
                gridInputs.append(contentsOf: [cc, nn])
            }

            onComplete(gridInputs)
        }

        a()
    }

    private func loadGridInput(_ cellKey: GridCellKey) -> (Double, Double) {

        let contentsAsNetSignal = cellKey.contents.asNetSignal
        let nutritionAsNetSignal: (CGFloat) -> Double = { Double($0) - 0.5 }

        if cellKey.contents == .invalid {
            return (contentsAsNetSignal, 0)
        }

        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        var nutrition: Double = 0

        switch cellKey.contents {
        case .arkon:
            nutrition = nutritionAsNetSignal(st.metabolism!.energyFullness)
            return (contentsAsNetSignal, nutrition)

        case .manna:
            guard let manna = cellKey.sprite?.getManna(require: false)
                else { fatalError() }

            let energy = manna.getEnergyContentInJoules()
            let energyAsNetSignal = nutritionAsNetSignal(energy)
            return (contentsAsNetSignal, energyAsNetSignal)

        case .nothing:
            return (contentsAsNetSignal, 0)

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

        Debug.log("makeCellShuttle for \(six(st.name)) from \(st.gridCell!)", level: 98)

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

        Debug.log("order for \(six(st.name)): \(order)", level: 98)

        let targetOffset = order.first { senseGrid.cells[$0.0] is HotKey }

        let fromCell: HotKey?
        let toCell: HotKey

        if targetOffset == nil || targetOffset!.0 == 0 {
            guard let t = senseGrid.cells[0] as? HotKey else { fatalError() }

            toCell = t; fromCell = nil
            Debug.log("toCell at \(t.gridPosition) holds \(six(t.sprite?.name))", level: 98)
        } else {
            guard let t = senseGrid.cells[targetOffset!.0] as? HotKey else { fatalError() }
            guard let f = senseGrid.cells[0] as? HotKey else { fatalError() }

            toCell = t; fromCell = f
            Debug.log("toCell at \(t.gridPosition) holds \(six(t.sprite?.name)), fromCell at \(f.gridPosition) holds \(six(f.sprite?.name))", level: 98)
        }

        if targetOffset == nil {
            Debug.log("targetOffset: nil", level: 98)
        } else {
            Debug.log("targetOffset: \(targetOffset!.0)", level: 98)
        }

        return CellShuttle(fromCell, toCell)
    }
}
