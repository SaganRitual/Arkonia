import CoreGraphics
import Dispatch

final class Plot: Dispatchable {
    var senseData: [Double]?
    var senseGrid: CellSenseGrid?

    static let dispatchQueue = DispatchQueue(
        label: "ak.plot.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .utility)
    )

    internal override func launch() { makeSenseGrid() }

    func makeSenseGrid() {
        guard let (ch, _, st) = scratch?.getKeypoints() else { preconditionFailure() }
        guard let hk = ch.engagerKey as? HotKey else { preconditionFailure() }

        writeDebug("Plot \(six(st.name))", scratch: ch)

        precondition(
            (ch.engagerKey == nil  ||
                (ch.engagerKey?.sprite?.getStepper(require: false)?.name == st.name &&
                ch.engagerKey?.gridPosition == st.gridCell.gridPosition &&
                ch.engagerKey?.sprite?.getStepper(require: false)?.gridCell.gridPosition == st.gridCell.gridPosition)
        ))

        precondition(hk.sprite?.getStepper(require: false) != nil)
        precondition(hk.sprite?.name == st.name)

        senseGrid = CellSenseGrid(
            from: hk,
            by: Arkonia.cSenseGridlets,
            block: st.previousShiftOffset
        )

        Log.L.write("SenseGrid cells \(senseGrid!.cells)", level: 61)

        Clock.shared.getEntropy { entropy in
            Plot.dispatchQueue.async { self.move(with: entropy) }
        }
    }

    func getSenseData(_ gridInputs: [Double]) {
        let nonSpatial = getNonSpatialSenseData()
        senseData = gridInputs + nonSpatial
    }

    func move(with entropy: CGFloat) {
        guard let sg = senseGrid else { preconditionFailure() }

        let gridInputs = loadGridInputs(from: sg, with: entropy)
        getSenseData(gridInputs)
        move()
    }

    func move() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { preconditionFailure() }
        guard let sg = senseGrid else { preconditionFailure() }
        guard let sd = senseData else { preconditionFailure() }

        ch.cellShuttle = makeCellShuttle(sd, sg)
        ch.engagerKey = nil

        dp.moveSprite()
        ch.stillCounter += ch.cellShuttle!.didMove ? 0.005 : 0.05

        Log.L.write("sc = \(ch.stillCounter)", level: 61)
    }

    deinit {
        Log.L.write("~Plot \(six(scratch?.stepper?.name))", level: 31)
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
