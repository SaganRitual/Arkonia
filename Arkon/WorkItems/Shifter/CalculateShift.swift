import SpriteKit

extension Shifter {

    func calculateShift() {
        let senseData = loadSenseData()
        dispatch.gridCellConnector = selectMoveTarget(senseData: senseData)
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

        let whereIAmNow = stepper.gridCell!
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

    private func selectMoveTarget(senseData: [Double]) -> SafeStage {
        let motorOutputs: [Double] = stepper.net.getMotorOutputs(senseData)
        let dMotorOutputs: [Int: Double] = self.getMotorDataAsDictionary(motorOutputs)

        let order: [(Int, Double)] = dMotorOutputs.sorted { lhs, rhs in
            Double(lhs.1) > Double(rhs.1)
        }

        guard let gcc = dispatch.gridCellConnector as? SafeSenseGrid else {
            fatalError()
        }

        let targetOffset = order.first { entry in
            guard let candidateCell = gcc.cells[entry.0] else { return false }
            return candidateCell.owner == stepper.name
        }

        guard let from = gcc.cells[0],
                let to = gcc.cells[targetOffset?.0 ?? 0] else { fatalError() }

        return SafeStage(from, to)
    }
}
