import CoreGraphics
import Dispatch

final class Plot: Dispatchable {
    var senseData: [Double]?

    internal override func launch() { plot() }

    private func plot() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Debug.log(level: 104) { "Plot \(six(st.name))" }

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
            Debug.log(level: 103) { "gridInputs \(gridInputs)" }
            guard let sd = self.senseData else { fatalError() }
            ch.cellShuttle = self.makeCellShuttle(sd, sg)
            d()
        }

        func d() { Grid.serialQueue.async(execute: e) }

        func e() {
            sg.releaseNonStageCells(keep: ch.cellShuttle!.toCell!)
            ch.engagerKey = nil
            Debug.log(level: 104) {
                "computeMove \(six(ch.name)) ->"
                + " \(ch.cellShuttle!.toCell?.contents ?? .invalid) to"
                + " \(ch.cellShuttle!.toCell?.gridPosition ?? AKPoint.zero),"
                + " \(ch.cellShuttle!.fromCell?.contents ?? .invalid) from"
                + " \(ch.cellShuttle!.fromCell?.gridPosition ?? AKPoint.zero)"
            }
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

        func b() { Grid.serialQueue.async(execute: c) }

        func c() {
            var gridInputs = [Double]()
            for ix in 0..<senseGrid.cells.count {
                let (content, nutrition) = self.loadGridInput(senseGrid.cells[ix])
                let nn = nutrition * entropyPerJoule
                gridInputs.append(contentsOf: [content, nn])
            }

            onComplete(gridInputs)
        }

        a()
    }

    private func loadGridInput(_ cellKey: GridCellKey) -> (Double, Double) {

        let contentsAsNetSignal = cellKey.contents.asNetSignal

        if cellKey.contents == .invalid {
            return (contentsAsNetSignal, 0)
        }

        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        switch cellKey.contents {
        case .arkon:
            return (contentsAsNetSignal, Double(st.metabolism!.energyFullness))

        case .manna:
            guard let manna = cellKey.sprite?.getManna(require: false)
                else { fatalError() }

            let energy = manna.getEnergyContentInJoules()
            let nutrition = Double(energy) / Double(Arkonia.maxMannaEnergyContentInJoules)
            return (contentsAsNetSignal, nutrition)

        case .nothing:
            return (contentsAsNetSignal, 0)

        case .invalid: fatalError()
        }
    }

    private func getNonSpatialSenseData() -> [Double] {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        var theData = [Double]()

        let radius = st.gridCell.randomScenePosition?.radius ?? 0
        let theta = st.gridCell.randomScenePosition?.theta ?? 0
        let normalRadius = (radius / Grid.shared.hypoteneuse)
        let constrainedTheta = theta.truncatingRemainder(dividingBy: 2 * CGFloat.pi)
        let normalTheta = constrainedTheta / (2 * CGFloat.pi)
        let positiveTheta = (normalTheta >= 0) ? normalTheta : 1 + normalTheta
        theData.append(contentsOf: [Double(normalRadius), Double(positiveTheta)])
        let x = st.gridCell.randomScenePosition?.x ?? 0
        let y = st.gridCell.randomScenePosition?.y ?? 0
        Debug.log(level: 103) { "x, y = \(x), \(y), r, theta = \(radius), \(theta)" }

        let hunger = Double(st.metabolism.hunger)
        let asphyxia = Double(st.metabolism.co2Level / Arkonia.co2MaxLevel)
        theData.append(contentsOf: [hunger, asphyxia])

        return theData
    }

    private func makeCellShuttle(_ senseData: [Double], _ senseGrid: CellSenseGrid) -> CellShuttle {
        guard let ch = scratch else { fatalError() }
        guard let st = ch.stepper else { fatalError() }
        guard let net = st.net else { fatalError() }

        Debug.log(level: 98) { "makeCellShuttle for \(six(st.name)) from \(st.gridCell!)" }

        let motorOutputs: [(Int, Double)] =
            zip(0..., net.getMotorOutputs(senseData)).map { data in
                let (ss, signal) = data
                let sSignal = String(format: "%-2.6f", signal)
                guard let dSignal = Double(sSignal) else { fatalError() }
                return(ss, dSignal)
        }

        let trimmed = motorOutputs.filter { abs($0.1) < 1.0 && $0.0 != 0 }

        let order = trimmed.sorted { lhs, rhs in
            let labs = lhs.1//abs(lhs.1)
            let rabs = rhs.1//abs(rhs.1)

            return labs > rabs
        }

        Debug.log(level: 102) { "order for \(six(st.name)): \(order)" }

        let targetOffset = order.first { senseGrid.cells[$0.0] is HotKey }

        let fromCell: HotKey?
        let toCell: HotKey

        if targetOffset == nil || targetOffset!.0 == 0 {
            guard let t = senseGrid.cells[0] as? HotKey else { fatalError() }

            toCell = t; fromCell = nil
            Debug.log(level: 104) { "toCell at \(t.gridPosition) holds \(six(t.sprite?.name))" }
        } else {
            guard let t = senseGrid.cells[targetOffset!.0] as? HotKey else { fatalError() }
            guard let f = senseGrid.cells[0] as? HotKey else { fatalError() }

            toCell = t; fromCell = f
            Debug.log(level: 104) {
                let m = senseGrid.cells.map { "\($0.gridPosition) \(type(of: $0)) \($0.contents)" }

                return "I am \(six(st.name))" +
                "; toCell at \(t.gridPosition) holds \(six(t.sprite?.name))" +
                ", fromCell at \(f.gridPosition) holds \(six(f.sprite?.name))\n" +
                "senseGrid(\(m)"
            }

            assert(fromCell?.contents ?? .nothing == .arkon)
        }

        if targetOffset == nil {
            Debug.log(level: 98) { "targetOffset: nil" }
        } else {
            Debug.log(level: 98) { "targetOffset: \(targetOffset!.0)" }
        }

        assert((fromCell?.contents ?? .arkon) == .arkon)
        return CellShuttle(fromCell, toCell)
    }
}
