import SpriteKit

extension Shift {

    func calculateShift() {
        let senseData = loadSenseData()
        self.shiftTarget = selectMoveTarget(senseData: senseData)
    }

    func getGridletCopies() {
        stepper.shiftTracker.beforeMoveStart = GridletCopy(from: stepper.gridlet, runType: runType)
        stepper.shiftTracker.beforeMoveStop = GridletCopy(from: self.shiftTarget!, runType: runType)
    }

    private func getMotorDataAsDictionary(_ senseData: [Double]) -> [Int: Double] {
        return senseData.enumerated().reduce([:]) { accumulated, pw in
            let (position, weight) = pw
            var t = accumulated
            t[position] = weight
            return t
        }
    }

    private func loadSenseData() -> [Double] {
        var (hackyRearrangedInputs, nutritionses) =
            self.sensoryInputs.reduce(into: ([Double](), [Double]()))
        {
            $0.0.append($1.0)
            $0.1.append($1.1)
        }

        let whereIAmNow = stepper.gridlet!
        let previousShift = stepper.previousShiftOffset

        hackyRearrangedInputs.append(contentsOf: nutritionses)

        let xGrid = Double(whereIAmNow.gridPosition.x)
        let yGrid = Double(whereIAmNow.gridPosition.y)
        hackyRearrangedInputs.append(contentsOf: [xGrid, yGrid])

        let xShift = Double(previousShift.x)
        let yShift = Double(previousShift.y)
        hackyRearrangedInputs.append(contentsOf: [xShift, yShift])

        let hunger = Double(stepper.metabolism.hunger)
        let asphyxia = Double(1 - (stepper.metabolism.oxygenLevel / 1))
        hackyRearrangedInputs.append(contentsOf: [hunger, asphyxia])

        return hackyRearrangedInputs
    }

    func releaseGridPoints() {
        assert(runType == .barrier)

        guard let sh = self.shiftTarget else { fatalError() }

        for gridlet in usableGridlets.dropFirst() where sh !== gridlet {
            gridlet.gridletIsEngaged = false
        }

        usableGridlets.removeAll(keepingCapacity: true)
    }

    private func selectMoveTarget(senseData: [Double]) -> Gridlet {
        let motorOutputs: [Double] = stepper.net.getMotorOutputs(senseData)
        let dMotorOutputs: [Int: Double] = self.getMotorDataAsDictionary(motorOutputs)

        let order: [(Int, Double)] = dMotorOutputs.sorted { lhs, rhs in
            Double(lhs.1) > Double(rhs.1)
        }

        let targetOffset = order.first { entry in
            let candidateGridPoint = stepper.getGridPointByIndex(entry.0)

            guard let candidateGridlet = Gridlet.atIf(candidateGridPoint)
                else { return false }

            if usableGridlets.contains(candidateGridlet) == false { return false }
            if candidateGridlet.contents != .arkon { return true }

            guard let candidateVictim = candidateGridlet.sprite?.userData?[SpriteUserDataKey.stepper] as? Stepper,
                    stepper.metabolism.mass > (candidateVictim.metabolism.mass * 1.25)
                else { return false }

            return true
        }

        guard let t = targetOffset else { return stepper.gridlet }
        let p = stepper.getGridPointByIndex(t.0)
        return Gridlet.at(p)
    }
}
