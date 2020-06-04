import CoreGraphics

extension Plotter {

    enum MotorIndex: Int, CaseIterable { case jumpSelector, jumpSpeed }

    func setRoute(
        _ senseData: [Double], _ senseGrid: SenseGrid,
        _ onComplete: @escaping (CellShuttle, Double) -> Void
    ) {
        let scratch = self.scratch!, stepper = scratch.stepper!, net = stepper.net!

        #if DEBUG
        Debug.log(level: 119) { "makeCellShuttle for \(six(stepper.name)) from \(stepper.gridCell!)" }
        Debug.log(level: 122) { "senseData \(senseData)" }
        #endif

        func a() { net.driveSignal(b) }

        func b() { Dispatch.dispatchQueue.async(execute: c) }

        func c() {
            // Divide the circle into cCellsWithinSenseRange slices
            let s0 = net.pMotorOutputs[MotorIndex.jumpSelector.rawValue]
            let s1 = s0 * Float(net.netStructure.cCellsWithinSenseRange)
            let s2 = floor(s1)
            let s3 = Int(s2)
            let motorOutput = s3

            let targetOffset = calculateTargetOffset(for: motorOutput, from: senseGrid.cells)

            guard let toCell = senseGrid.cells[targetOffset] as? GridCell else {
                scratch.dispatch?.apoptosize(); return
            }

            let fromCell = (targetOffset > 0) ? senseGrid.cells[0] as? GridCell : nil

            let jumpSpeedMotorOutput = scratch.stepper.net.pMotorOutputs[MotorIndex.jumpSpeed.rawValue]

            if let f = fromCell {
                let asPercentage = max(CGFloat(jumpSpeedMotorOutput), 0.1)
                let jumpDistanceInCells = f.gridPosition.asPoint().distance(to: toCell.gridPosition.asPoint())

                scratch.jumpSpec = JumpSpec(jumpDistanceInCells, asPercentage)

                let isAlive = stepper.metabolism.applyJumpCosts(scratch.jumpSpec)

                if !isAlive {
                    scratch.dispatch!.apoptosize()
                    return
                }
            }

            onComplete(CellShuttle(fromCell, toCell), Double(jumpSpeedMotorOutput))
        }

        a()
    }

    func calculateTargetOffset(for motorOutput: Int, from cells: ContiguousArray<GridCellProtocol?>) -> Int {
        // Try to use the selected motor output, ie, jump to that square on
        // the grid. But if that square is occupied, find one that's not, and
        // jump to that one. A "jump" to cells[0] means we'll just stand still.

        let cCellsWithinSenseRange = scratch.stepper.net.netStructure.cCellsWithinSenseRange
        for m in 0..<cCellsWithinSenseRange {
            let select = (m + motorOutput) % cCellsWithinSenseRange
            let cell = cells[select]

            switch cell {
            case let c as GridCell:
                if c.stepper == nil || select == 0 { return select }
            case is NilKey:
                return select
            default:
                break
            }
        }

        fatalError()
    }
}
