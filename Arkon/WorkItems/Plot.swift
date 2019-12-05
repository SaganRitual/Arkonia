import Dispatch

final class Plot: Dispatchable {
    weak var scratch: Scratchpad?
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    private func launch_() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { preconditionFailure() }
        guard let cc = ch.cellConnector else { preconditionFailure() }

        let senseGrid = makeSenseGrid(from: cc, block: st.previousShiftOffset)
        let gridInputs = loadGridInputs(from: senseGrid)
        let nonSpatial = getNonSpatialSenseData()
        let senseData = gridInputs + nonSpatial

        ch.cellTaxi = makeCellTaxi(senseData, senseGrid)
        Log.L.write("plot \(six(st.name)), \(ch.cellTaxi == nil), \(ch.cellTaxi?.toCell == nil), \(ch.cellTaxi?.toCell?.cell == nil))", level: 31)

        dp.moveSprite()
    }

    deinit {
        Log.L.write("~Plot \(six(scratch?.stepper?.name))", level: 31)
    }
}

extension Plot {
    private func loadGridInputs(from senseGrid: CellSenseGrid) -> [Double] {
        let gridInputs: [Double] = senseGrid.cells.reduce([]) { partial, cell in

            guard let (contents, nutritionalValue) = loadGridInput(cell)
                else { return partial + [0, 0] }

            return partial + [contents, nutritionalValue]
        }

        return gridInputs
    }

    private func loadGridInput(_ cellKey: GridCellKey) -> (Double, Double)? {

        if cellKey.contents == .invalid {
            let rv = (GridCell.Contents.invalid.rawValue + 1)
            return (rv / Double(GridCell.Contents.allCases.count), 0)
        }

        guard let (_, _, st) = scratch?.getKeypoints() else { preconditionFailure() }

        let nutrition: Double

        switch cellKey.contents {
        case .arkon:
            nutrition = Double(st.metabolism.energyFullness)

        case .manna:
            let sprite = cellKey.sprite!
            guard let manna = Manna.getManna(from: sprite) else { fatalError() }
            nutrition = Double(manna.energyFullness)

        case .nothing: nutrition = 0
        case .invalid: fatalError()
        }

        return ((cellKey.contents.rawValue + 1) / Double(GridCell.Contents.allCases.count), nutrition)
    }

    private func getNonSpatialSenseData() -> [Double] {
        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        var theData = [Double]()

        let hunger = Double(st.metabolism.hunger)
        let asphyxia = Double(1 - (st.metabolism.oxygenLevel / 1))
        theData.append(contentsOf: [hunger, asphyxia])

        return theData
    }

    func makeSenseGrid(from gridCenter: HotKey, block: AKPoint) -> CellSenseGrid {
        return CellSenseGrid(from: gridCenter, by: ArkoniaCentral.cSenseGridlets, block: block)
    }

    private func makeCellTaxi(_ senseData: [Double], _ senseGrid: CellSenseGrid) -> CellTaxi {
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

        Log.L.write("order \(order)", level: 33)

        let targetOffset = order.first { senseGrid.cells[$0.0] is HotKey }

        let fromCell: HotKey?
        let toCell: HotKey

        if targetOffset == nil || targetOffset!.0 == 0 {
            guard let t = senseGrid.cells[0] as? HotKey else { preconditionFailure() }

            toCell = t; fromCell = nil
        } else {
            guard let t = senseGrid.cells[targetOffset!.0] as? HotKey else { preconditionFailure() }
            guard let f = senseGrid.cells[0] as? HotKey else { preconditionFailure() }

            toCell = t; fromCell = f
        }

        if targetOffset == nil {
            Log.L.write("targetOffset: nil", level: 33)
        } else {
            Log.L.write("targetOffset: \(targetOffset!.0)", level: 33)
        }

        return CellTaxi(fromCell, toCell)
    }
}
