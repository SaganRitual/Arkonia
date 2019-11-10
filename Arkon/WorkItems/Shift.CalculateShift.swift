import SpriteKit

extension Shift {

    func calculateShift() {
        let senseData = loadSenseData()
        self.shiftTarget = selectMoveTarget(senseData: senseData)
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
            if let gridletCopy = $1 {
                $0.0.append(gridletCopy.0)
                $0.1.append(gridletCopy.1)
            } else {
                $0.0.append(0)
                $0.1.append(0)
            }
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
        print("release, keep", t.gridPosition, "from", gridletEngager.gridletFrom?.owner ?? "no owner", "to", gridletEngager.gridletTo?.owner ?? "no owner")
        gridletEngager.disengage(keep: t.gridPosition, awaken: true)
        print("release, disengaged", t.gridPosition, "from", gridletEngager.gridletFrom?.owner ?? "no owner", "to", gridletEngager.gridletTo?.owner ?? "no owner")
    }

    private func selectMoveTarget(senseData: [Double]) -> GridletCopy {
        let motorOutputs: [Double] = stepper.net.getMotorOutputs(senseData)
        let dMotorOutputs: [Int: Double] = self.getMotorDataAsDictionary(motorOutputs)

        let order: [(Int, Double)] = dMotorOutputs.sorted { lhs, rhs in
            Double(lhs.1) > Double(rhs.1)
        }

        let targetOffset = order.first { entry in
            guard let candidateGridletCopy = gridletEngager.gridletCopies[entry.0]
                else { return false }

            return candidateGridletCopy.owner == stepper.name
        }

        guard let t = targetOffset else { return stepper.gridlet.copy() }
        guard let c = self.gridletEngager.gridletCopies[t.0] else { fatalError() }
        return c
    }
}
