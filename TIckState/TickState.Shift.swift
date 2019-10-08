import GameplayKit

extension TickState {
    class Shift: TickStateBase {
        var shiftTarget = AKPoint.zero
        var usableGridOffsets = [AKPoint]()

        deinit { releaseGridPoints() }

        override func enter() {
            reserveGridPoints()
        }

        override func work() -> TickState {
//            print("st: shiftable")
            let shiftable = calculateShift()

            if shiftable { shift(); return .nop }

            return .start
        }
    }
}

// Action calls

extension TickState.Shift {
    func shift() {
        guard let gridPosition = stepper?.gridlet.gridPosition else {
            print("stepper gone in shift")
            return
        }

        let newGridlet = Gridlet.at(gridPosition + shiftTarget)
        let goStep = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)
        let postscript = SKAction.run { [weak self] in
//            print("ps1")
            newGridlet.isEngaged = false
            self?.statum?.statumLeave(to: .arrive)
        }

        statum?.action = SKAction.sequence([goStep, postscript])
        statum?.actioner = stepper?.sprite
    }
}

// Sync calls

extension TickState.Shift {
    func reserveGridPoints() {
        usableGridOffsets = Stepper.moves.compactMap { offset in
            guard let gridPosition = stepper?.gridlet.gridPosition else {
                fatalError()
            }

            let targetGridPoint = gridPosition + offset
            if Gridlet.isOnGrid(targetGridPoint.x, targetGridPoint.y) {
                let targetGridlet = Gridlet.at(targetGridPoint)

                if targetGridlet.isEngaged { return nil }

                // If there's no arkon in our target cell, then we
                // can go there if we want
                if targetGridlet.contents != .arkon {
                    targetGridlet.isEngaged = true
                    return offset
                }

                guard let intendedVictim = targetGridlet.sprite?.stepper else { fatalError() }

                if !intendedVictim.isAlive { return nil }
                if intendedVictim.tickStatum?.syncState != .sync { return nil }

                // Not sure about this one; seems like it wouldn't be good for
                // us to be mussing about with other arkons while actions are
                // running?
                if Display.displayCycle == .actions { return nil }

                defer {
                    intendedVictim.isEngaged = true
                    targetGridlet.isEngaged = true
                }

                // If there's an arkon in our target cell that isn't engaged,
                // we can go attack it if we want
                if !intendedVictim.isEngaged { return offset }
            }

//            print("tgq")
            return nil
        }
    }
}

// Async calls

extension TickState.Shift {
    func calculateShift() -> Bool {
        guard let s = self.stepper else { return false }

        let senseData = s.loadSenseData()
        shiftTarget = s.selectMoveTarget(senseData, usableGridOffsets)

        releaseGridPoints(keep: shiftTarget)

        return shiftTarget != AKPoint.zero
    }

    func releaseGridPoints(keep: AKPoint? = nil) {
        for gridOffset in usableGridOffsets {
            if keep == nil || keep! != gridOffset {
                guard let gridPosition = stepper?.gridlet.gridPosition else {
                    return
                }

                Gridlet.at(gridPosition + gridOffset).isEngaged = false
            }
        }

        usableGridOffsets.removeAll(keepingCapacity: true)
    }
}
