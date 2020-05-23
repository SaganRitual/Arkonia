import CoreGraphics

extension Plotter {

    enum MotorIndex: Int { case jumpSelector, jumpSpeed }

    func setRoute(
        _ senseData: [Double], _ senseGrid: SenseGrid,
        _ onComplete: @escaping (CellShuttle, Double) -> Void
    ) {
        let scratch = (self.scratch)!
        let stepper = (scratch.stepper)!
        let net = (stepper.net)!

        #if DEBUG
        Debug.log(level: 119) { "makeCellShuttle for \(six(stepper.name)) from \(stepper.gridCell!)" }
        Debug.log(level: 122) { "senseData \(senseData)" }
        #endif

        var motorOutputs = [Double]()

        func a() {
            net.getMotorOutputs(senseData) {
                motorOutputs = $0
                Dispatch.dispatchQueue.async(execute: b)
            }
        }

        func b() {
            // Divide the circle into cMotorGridlets + 1 slices
            let s0 = motorOutputs[MotorIndex.jumpSelector.rawValue]
            let s1 = s0 * Double(Arkonia.cMotorGridlets + 1)
            let s2 = floor(s1)
            let s3 = Int(s2)
            let motorOutput = s3

            let targetOffset = calculateTargetOffset(for: motorOutput, from: senseGrid.cells)

            let toCell = (senseGrid.cells[targetOffset] as? GridCell)!

            let fromCell = (targetOffset > 0) ? senseGrid.cells[0] as? GridCell : nil

            let jumpSpeedMotorOutput = motorOutputs[MotorIndex.jumpSpeed.rawValue]

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

            onComplete(CellShuttle(fromCell, toCell), jumpSpeedMotorOutput)
        }

        a()
    }

    func calculateTargetOffset(for motorOutput: Int, from cells: [GridCellProtocol?]) -> Int {
        #if DEBUG
        for c in cells {
            hardAssert((c is GridCell) == (c!.ownerName == cells[0]!.ownerName), "hardAssert at \(#file):\(#line)")
            hardAssert(((c as? GridCell)?.isLocked ?? false) || !(c is GridCell), "hardAssert at \(#file):\(#line)")
        }
        #endif

        // Try to use the selected motor output, ie, jump to that square on
        // the grid. But if that square is occupied, find one that's not, and
        // jump to that one. A "jump" to cells[0] means we'll just stand still.

        for m in 0..<Arkonia.cMotorGridlets {
            let select = (m + motorOutput) % Arkonia.cMotorGridlets
            if let cell = cells[select] as? GridCell,
                  (cell.stepper == nil || select == 0) {
                return select
            }
        }

        fatalError()
    }
}
