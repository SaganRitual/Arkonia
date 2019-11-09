import SpriteKit

extension Shift {

    func calculateShift() {
        let senseData = loadSenseData()
        self.shiftTarget = selectMoveTarget(senseData: senseData)
    }

    func getGridletCopies() {
        stepper.shiftTracker.beforeMoveStart = GridletCopy(from: stepper.gridlet)
        stepper.shiftTracker.beforeMoveStop = GridletCopy(from: self.shiftTarget!)
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

        guard let t = self.shiftTarget else { fatalError() }
        gridletEngager.disengage(keep: t.gridPosition)
    }

    private func selectMoveTarget(senseData: [Double]) -> GridletCopy {
        let motorOutputs: [Double] = stepper.net.getMotorOutputs(senseData)
        let dMotorOutputs: [Int: Double] = self.getMotorDataAsDictionary(motorOutputs)

        let order: [(Int, Double)] = dMotorOutputs.sorted { lhs, rhs in
            Double(lhs.1) > Double(rhs.1)
        }

        let targetOffset = order.first { entry in
            let candidateGridletCopy = gridletEngager.gridletCopies[entry.0]

            return candidateGridletCopy.owner == stepper.name
        }

        guard let t = targetOffset else { return stepper.gridlet.copy() }
        return self.gridletEngager.gridletCopies[t.0]
    }
}
