import Dispatch

final class Plot: Dispatchable {
    var senseData: [Double]?
    var senseGrid: CellSenseGrid?
    var wiLaunch2: DispatchWorkItem?
    var wiLaunch3: DispatchWorkItem?

    internal override func launch_() {
        guard let (ch, _, st) = scratch?.getKeypoints() else { preconditionFailure() }
        guard let cc = ch.cellConnector_ else { preconditionFailure() }

        senseGrid = makeSenseGrid(from: cc, block: st.previousShiftOffset)

        self.wiLaunch2 = DispatchWorkItem { [weak self] in self?.launch2_() }
        World.shared.concurrentQueue.async(execute: self.wiLaunch2!)
    }

    func launch2_() {
        guard let sg = senseGrid else { preconditionFailure() }

        let gridInputs = loadGridInputs(from: sg)
        let nonSpatial = getNonSpatialSenseData()
        senseData = gridInputs + nonSpatial

        self.wiLaunch3 = DispatchWorkItem { [weak self] in self?.launch3_() }
        Grid.shared.serialQueue.async(execute: self.wiLaunch3!)
    }

    func launch3_() {
        guard let (ch, dp, _) = scratch?.getKeypoints() else { preconditionFailure() }
        guard let sg = senseGrid else { preconditionFailure() }
        guard let sd = senseData else { preconditionFailure() }

        ch.cellTaxi_ = makecellTaxi_(sd, sg)
        ch.cellConnector_ = nil
        self.senseGrid = nil
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
        let asphyxia = Double(1 - st.metabolism.oxygenLevel)
        theData.append(contentsOf: [hunger, asphyxia])

        return theData
    }

    func makeSenseGrid(from gridCenter: HotKey, block: AKPoint) -> CellSenseGrid {
        return CellSenseGrid(from: gridCenter, by: ArkoniaCentral.cSenseGridlets, block: block)
    }

    private func makecellTaxi_(_ senseData: [Double], _ senseGrid: CellSenseGrid) -> cellTaxi_ {
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

        let trimmed = motorOutputs.filter { _ in true }// { abs($0.1) < 1.0 && $0.0 != 0 }

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

        return cellTaxi_(fromCell, toCell)
    }
}
