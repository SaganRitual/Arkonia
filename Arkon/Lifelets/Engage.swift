import Dispatch

final class Engage: Dispatchable {
    internal override func launch() { Grid.arkonsPlaneQueue.async { self.engage(.arkonsPlane) } }

    private func engage(_ catchDumbMistakes: DispatchQueueID) {
        hardAssert(scratch.engagerKey == nil) { "hardAssert at \(#file):\(#line)" }

        Debug.log(level: 188) { "Engage \(six(scratch.stepper.name)) at \(scratch.stepper.gridCell.gridPosition)" }
        Debug.debugColor(scratch.stepper, .red, .yellow)

        let isEngaged = self.engageIf(catchDumbMistakes)
        guard isEngaged else {
            Debug.log(level: 168) { "Engage failed for \(six(scratch.stepper.name))" }
            return
        }
        Debug.debugColor(scratch.stepper, .red, .green)

        self.makeSenseGrid(catchDumbMistakes)
        scratch.dispatch!.tickLife()
    }

    private func engageIf(_ catchDumbMistakes: DispatchQueueID) -> Bool {
        hardAssert(scratch.engagerKey == nil) { "hardAssert at \(#file):\(#line)" }

        let gc = scratch.stepper.gridCell!

        if let ek = gc.getLock(
            for: scratch.stepper, .degradeToCold, catchDumbMistakes
        ) as? GridCell { scratch.engagerKey = ek; return true }

        // Even if we don't move, you can't argue with Lord Kelvin
        scratch.tickBacklog += 1

        return false
    }

    private func makeSenseGrid(_ catchDumbMistakes: DispatchQueueID) {
        let hk = scratch.engagerKey!

        Debug.log(level: 185) {
            "senseGrid.0 for \(scratch.stepper.name) at \(hk.gridPosition)"
        }

        if scratch.senseGrid == nil {
            let c = scratch.stepper.net.netStructure.cCellsWithinSenseRange
            scratch.senseGrid = SenseGrid(scratch.stepper, cCellsWithinSenseRange: c)
        }

        scratch.senseGrid!.assembleGrid(
            center: hk, block: scratch.stepper.previousShiftOffset, catchDumbMistakes
        )

        #if DEBUG
        Debug.log(level: 185) {
            let m: [String] = scratch.senseGrid!.cells.map { cell in
                let key: String

                switch cell {
                case is GridCell: key = "hot"
                case is ColdKey:  key = "cold"
                case is NilKey:   key = "nil"

                default: fatalError()
                }

                return "\(key)\(cell!.gridPosition)"
            }

            return "senseGrid.1 for \(scratch.stepper.name) \(m)"
        }
        #endif
    }
}

extension GridCell {
    func getLock(for stepper: Stepper, _ require: RequireLock, _ catchDumbMistakes: DispatchQueueID) -> GridCellProtocol? {
        let key = lock(require: require, ownerName: stepper.name, catchDumbMistakes)

        #if DEBUG
        Debug.log(level: 185) { "getLock4 for \(six(stepper.name))" }
        #endif

        Debug.debugColor(stepper, .red, .blue)
        if key is ColdKey {
            #if DEBUG
            Debug.log(level: 185) { "getLock4.5 for \(six(stepper.name))" }
            #endif

            hardAssert(isLocked && ownerName != stepper.name) { "hardAssert at \(#file):\(#line)" }
            reschedule(stepper, catchDumbMistakes)
            Debug.debugColor(stepper, .red, .black)
        }

        return key
    }
}