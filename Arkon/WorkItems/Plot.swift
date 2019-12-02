import Dispatch

final class Plot: Dispatchable {
    weak var scratch: Scratchpad?
    var senseData = [Double]()
    var wiLaunch: DispatchWorkItem?

    init(_ scratch: Scratchpad) {
        self.scratch = scratch
        self.wiLaunch = DispatchWorkItem(block: launch_)
    }

    private func launch_() {
        guard let (ch, dp, st) = scratch?.getKeypoints() else { fatalError() }
        st.nose.color = .gray

        guard let centerCell =
            ch.getCellConnector(require: true) else { preconditionFailure() }

        let senseGrid = makeSenseGrid(from: centerCell)
        ch.setGridConnector(senseGrid)

        loadSenseData()

        let stage = stageMovement()
        ch.setGridConnector(stage)

        dp.moveSprite()
    }
}

extension Plot {
    private func loadGridInputs() -> [Double] {
        guard let senseGrid = scratch?.getSensesConnector() else { fatalError() }

        let gridInputs: [Double] = senseGrid.cells.reduce([]) { partial, cell in

            guard let (contents, nutritionalValue) = loadGridInput(cell)
                else { return partial + [0, 0] }

            return partial + [contents, nutritionalValue]
        }

        return gridInputs
    }

    private func loadGridInput(_ c: SafeCell?) -> (Double, Double)? {

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

        case .nothing: nutrition = 0
        case .invalid: fatalError()
        }

        return ((cell.contents.rawValue + 1) / Double(GridCell.Contents.allCases.count), nutrition)
    }

    private func loadSenseData() {
        self.senseData = loadGridInputs()

        guard let (_, _, st) = scratch?.getKeypoints() else { fatalError() }

        let previousShift = st.previousShiftOffset

        let xShift = Double(previousShift.x)
        let yShift = Double(previousShift.y)
        senseData.append(contentsOf: [xShift, yShift])

        let hunger = Double(st.metabolism.hunger)
        let asphyxia = Double(1 - (st.metabolism.oxygenLevel / 1))
        senseData.append(contentsOf: [hunger, asphyxia])
    }

    func makeSenseGrid(from gridCenter: SafeCell) -> SafeSenseGrid {
        return SafeSenseGrid(from: gridCenter, by: ArkoniaCentral.cMotorGridlets)
    }

    private func stageMovement() -> SafeStage {
        guard let ch = scratch else { fatalError() }
        guard let st = ch.stepper else { fatalError() }

        let motorOutputs =
            zip(0..., st.net.getMotorOutputs(senseData)).map { ($0, $1) }

        let order = motorOutputs.sorted { lhs, rhs in lhs.1 > rhs.1 }
        let senseGrid = ch.getSensesConnector(require: false)

        let targetOffset = order.first { entry in
            guard let candidateCell = senseGrid?.cells[entry.0] else { return false }

            return candidateCell.isHot
        }

        let fromCell: SafeCell?
        let toCell: SafeCell

        if targetOffset == nil || targetOffset!.0 == 0 {
            toCell = (senseGrid?.cells[0])!; fromCell = nil
        } else {
            toCell = (senseGrid?.cells[targetOffset!.0])!; fromCell = senseGrid?.cells[0]
        }

        precondition(toCell.isHot && (fromCell == nil || fromCell!.isHot))

        return SafeStage(fromCell, toCell)
    }
}
