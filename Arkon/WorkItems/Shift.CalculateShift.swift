import SpriteKit

extension Shift {

    func calculateShift() {
        let senseData = loadSenseData()
        self.shiftTarget = selectMoveTarget(senseData: senseData)

        releaseGridPoints()
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

    private func releaseGridPoints() {
        let whereIAmNow = stepper.gridlet!

        for gridOffset in usableGridOffsets {

            if self.shiftTarget == nil ||
                self.shiftTarget! != gridOffset
            {
                let targetGridlet =  Gridlet.at(whereIAmNow.gridPosition + gridOffset)
                targetGridlet.gridletIsEngaged = false
            }
        }

        usableGridOffsets.removeAll(keepingCapacity: true)
    }

    private func selectMoveTarget(senseData: [Double]) -> AKPoint {
        let motorOutputs: [Double] = stepper.net.getMotorOutputs(senseData)
        let dMotorOutputs: [Int: Double] = self.getMotorDataAsDictionary(motorOutputs)

        let order: [(Int, Double)] = dMotorOutputs.sorted { lhs, rhs in
            Double(lhs.1) > Double(rhs.1)
        }

        var targetShift = AKPoint.zero
        let targetMove = order.first { entry in
            targetShift = Grid.moves[entry.0]
            return usableGridOffsets.contains(targetShift)
        }

        guard let tm = targetMove else { return AKPoint.zero }
        return Grid.moves[tm.0]
    }
}
