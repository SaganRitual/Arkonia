import CoreGraphics
import Dispatch

final class Plot: Dispatchable {
    var senseData: [Double]?
    var senseGrid: CellSenseGrid?

    internal override func launch() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        Log.L.write("Plot \(six(st.name))", level: 71)

        var entropy: CGFloat = 0

        func a() {
            Log.L.write("Plot2 \(six(st.name))", level: 71)
            self.makeSenseGrid(b) }
        func b() {
            Log.L.write("Plot3 \(six(st.name))", level: 71)
            self.getEntropy {
                Log.L.write("Plot4 \(six(st.name))", level: 71)
                entropy = $0; c() } }
        func c() {
            Log.L.write("Plot5 \(six(st.name))", level: 71)
            self.computeMove(with: entropy, d) }

        func d() {
            Log.L.write("Plot6 \(six(st.name))", level: 71)
            ch.stillCounter += ch.cellShuttle!.didMove ? 0.005 : 0.05
            e()
        }

        func e() {
            Log.L.write("Plot7 \(six(st.name))", level: 71)
            dp.moveSprite() }

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

    func getEntropy(_ onComplete: @escaping (CGFloat) -> Void) {
        Clock.dispatchQueue.async { onComplete(Clock.shared.getEntropy()) }
    }

    func getSenseData(_ gridInputs: [Double]) {
        let nonSpatial = getNonSpatialSenseData()
        senseData = gridInputs + nonSpatial
    }

    func computeMove(with entropy: CGFloat, _ onComplete: @escaping () -> Void) {
        guard let (ch, _, _) = scratch?.getKeypoints() else { fatalError() }
        guard let sg = senseGrid else { fatalError() }

        Grid.serialQueue.async {
            let gridInputs = self.loadGridInputs(from: sg, with: entropy)
            precondition(gridInputs.count == Arkonia.cSenseNeuronsSpatial)

            self.getSenseData(gridInputs)

            guard let sd = self.senseData else { fatalError() }
            ch.cellShuttle = self.makeCellShuttle(sd, sg)

            onComplete()
        }
    }
}

extension Plot {
    private func loadGridInputs(from senseGrid: CellSenseGrid, with entropy: CGFloat) -> [Double] {
        let gridInputs: [Double] = senseGrid.cells.reduce([]) { partial, cell in
            guard let (contents, nutritionalValue) = loadGridInput(cell, with: entropy) else {
                return partial + [0, 0]
            }

            return partial + [contents, nutritionalValue]
        }

        return gridInputs
    }

    private func loadGridInput(_ cellKey: GridCellKey, with entropy: CGFloat) -> (Double, Double)? {

        if cellKey.contents == .invalid {
            let rv = (GridCell.Contents.invalid.rawValue + 1)
            return (rv / Double(GridCell.Contents.allCases.count), 0)
        }

        guard let (_, _, st) = scratch?.getKeypoints() else { preconditionFailure() }

        let nutrition: Double

        switch cellKey.contents {
        case .arkon:
            nutrition = Double(st.metabolism.energyFullness) - 0.5

        case .manna:
            guard let manna = cellKey.sprite?.getManna(require: false)
                else { fatalError() }

            nutrition = Double(manna.getEnergyContentInJoules(entropy)) - 0.5

        case .nothing: nutrition = 0
        case .invalid: fatalError()
        }

        return ((cellKey.contents.rawValue + 1) / Double(GridCell.Contents.allCases.count + 1), nutrition)
    }

    private func getNonSpatialSenseData() -> [Double] {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        var theData = [Double]()

        let r = Double(st.gridCell.randomScenePosition?.radius ?? 0)
        let t = Double(st.gridCell.randomScenePosition?.theta ?? 0)
        let ro = (r / Grid.dimensions.hypotenuse) - 0.5
        let to = (t / Grid.dimensions.hypotenuse) - 0.5
        theData.append(contentsOf: [to, ro])

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

        Log.L.write("order for \(six(st.name)): \(order)", level: 62)

        let targetOffset = order.first { senseGrid.cells[$0.0] is HotKey }

        let fromCell: HotKey?
        let toCell: HotKey

        if targetOffset == nil || targetOffset!.0 == 0 {
            guard let t = senseGrid.cells[0] as? HotKey else { preconditionFailure() }

            toCell = t; fromCell = nil
            Log.L.write("toCell at \(t.gridPosition)", level: 55)
        } else {
            guard let t = senseGrid.cells[targetOffset!.0] as? HotKey else { preconditionFailure() }
            guard let f = senseGrid.cells[0] as? HotKey else { preconditionFailure() }

            toCell = t; fromCell = f
            Log.L.write("toCell at \(t.gridPosition), fromCell at \(f.gridPosition)", level: 55)
        }

        if targetOffset == nil {
            Log.L.write("targetOffset: nil", level: 53)
        } else {
            Log.L.write("targetOffset: \(targetOffset!.0)", level: 53)
        }

        return CellShuttle(fromCell, toCell)
    }
}
