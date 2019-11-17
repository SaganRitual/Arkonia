import Dispatch

class Plot: Dispatchable {
    weak var scratch: Scratchpad?
    var senseData = [Double]()
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(flags: [], block: launch_)
    }

    func launch() {
        guard let w = wiLaunch else { fatalError() }
        Grid.shared.concurrentQueue.async(execute: w)
    }

    private func launch_() {
        loadSenseData()

        guard let (ch, dp, _) = scratch?.getKeypoints() else { fatalError() }

        ch.gridCellConnector = selectMoveTarget()
        dp.moveSprite(wiLaunch!)
    }
}

extension Plot {
    private func loadGridInputs() -> [Double] {
        guard let senseGrid = scratch?.senseGrid else { fatalError() }

        let gridInputs: [Double] = senseGrid.cells.reduce([]) { partial, cell in

            guard let (contents, nutritionalValue) = loadGridInput_(cell)
                else { return partial + [0, 0] }

            return partial + [contents, nutritionalValue]
        }

        return gridInputs
    }

    private func loadGridInput_(_ c: SafeCell?) -> (Double, Double)? {

        guard let cell = c, GridCell.isOnGrid(cell.gridPosition) else {
            let rv = (GridCell.Contents.invalid.rawValue + 1)
            return (rv / Double(GridCell.Contents.allCases.count), 0)
        }

        guard let scr = scratch else { fatalError() }
        guard let st = scr.stepper else { fatalError() }

        let nutrition: Double

        switch cell.contents {
        case .arkon:
            nutrition = Double(st.metabolism.energyFullness)

        case .manna:
            let sprite = cell.sprite!
            guard let manna = Manna.getManna(from: sprite) else { fatalError() }
            nutrition = Double(manna.energyFullness)

        case .myself:  nutrition = 0
        case .nothing: nutrition = 0
        case .invalid: fatalError()
        }

        return ((cell.contents.rawValue + 1) / Double(GridCell.Contents.allCases.count), nutrition)
    }

    private func loadSenseData() {
        var senseData = loadGridInputs()

        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        let previousShift = st.previousShiftOffset

        let xShift = Double(previousShift.x)
        let yShift = Double(previousShift.y)
        senseData.append(contentsOf: [xShift, yShift])

        let hunger = Double(st.metabolism.hunger)
        let asphyxia = Double(1 - (st.metabolism.oxygenLevel / 1))
        senseData.append(contentsOf: [hunger, asphyxia])
    }

    private func selectMoveTarget() -> SafeStage {
        guard let ch = scratch else { fatalError() }
        guard let st = ch.stepper else { fatalError() }

        let motorOutputs =
            zip(0..., st.net.getMotorOutputs(senseData)).map { ($0, $1) }

        let order = motorOutputs.sorted { lhs, rhs in lhs.1 > rhs.1 }

        let targetOffset = order.first { entry in
            guard let candidateCell = ch.senseGrid.cells[entry.0] else { return false }
            return candidateCell.owner == st.name
        }

        guard let from = ch.senseGrid.cells[0],
                let to = ch.senseGrid.cells[targetOffset?.0 ?? 0] else { fatalError() }

        return SafeStage(from, to)
    }
}
