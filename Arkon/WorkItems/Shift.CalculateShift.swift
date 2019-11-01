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
            $0.0.append($1.0)
            $0.1.append($1.1)
        }

        let whereIAmNow = stepper.gridlet!
        let previousShift = stepper.previousShift

        hackyRearrangedInputs.append(contentsOf: nutritionses)

        let xGrid = Double(whereIAmNow.gridPosition.x)
        let yGrid = Double(whereIAmNow.gridPosition.y)
        hackyRearrangedInputs.append(contentsOf: [xGrid, yGrid])

        let xShift = Double(previousShift.x)
        let yShift = Double(previousShift.y)
        hackyRearrangedInputs.append(contentsOf: [xShift, yShift])

        return hackyRearrangedInputs
    }

    func releaseGridPoints() {
        for gridlet in usableGridlets {
            guard let sh = self.shiftTarget else { fatalError() }
            if sh !== gridlet {
                gridlet.gridletIsEngaged = false
            }
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
            let candidateOffset = Grid.moves[entry.0]

            let stepperGridPoint = stepper.gridlet.gridPosition

            guard let candidateGridlet = Gridlet.atIf(
                stepperGridPoint + candidateOffset
            ) else {
                return false
            }

            return usableGridlets.contains(candidateGridlet)
        }

        guard let t = targetOffset else { return stepper.gridlet }
        return stepper.gridlet + Grid.moves[t.0]
    }
}
