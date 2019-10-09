import SpriteKit

extension Shift {
    func calculateShift(
        from whereIAmNow: Gridlet, previousShift: AKPoint
    ) -> Bool {
        let senseData = loadSenseData(near: whereIAmNow, previousShift: previousShift)

        guard let st = stepper else { fatalError() }
        st.shiftTarget = selectMoveTarget(
            core: st.core, senseData, usableGridOffsets
        )

        releaseGridPoints(whereIAmNow: whereIAmNow, keep: st.shiftTarget)

        return st.shiftTarget != AKPoint.zero
    }

    private func getMotorDataAsDictionary(_ senseData: [Double]) -> [Int: Double] {
        return senseData.enumerated().reduce([:]) { accumulated, pw in
            let (position, weight) = pw
            var t = accumulated
            t[position] = weight
            return t
        }
    }

    private func loadSenseData(near whereIAmNow: Gridlet, previousShift: AKPoint) -> [Double] {
        var (sensoryInputs, nutritionses) =
            self.sensoryInputs.reduce(into: ([Double](), [Double]()))
        {
            $0.0.append($1.0)
            $0.1.append($1.1)
        }

        sensoryInputs.append(contentsOf: nutritionses)

        let xGrid = Double(whereIAmNow.gridPosition.x)
        let yGrid = Double(whereIAmNow.gridPosition.y)
        sensoryInputs.append(contentsOf: [xGrid, yGrid])

        let xShift = Double(previousShift.x)
        let yShift = Double(previousShift.y)
        sensoryInputs.append(contentsOf: [xShift, yShift])

        return sensoryInputs
    }

    private func releaseGridPoints(whereIAmNow: Gridlet, keep: AKPoint? = nil) {
        for gridOffset in usableGridOffsets {
            if keep == nil || keep! != gridOffset {
                Gridlet.at(whereIAmNow.gridPosition + gridOffset).isEngaged = false
            }
        }

        usableGridOffsets.removeAll(keepingCapacity: true)
    }

    private func selectMoveTarget(
        core: Arkon, _ sensoryInputs: [Double], _ usableOffsets: [AKPoint]
    ) -> AKPoint {

        let motorOutputs: [Double] = core.net.getMotorOutputs(sensoryInputs)
        let dMotorOutputs: [Int: Double] = self.getMotorDataAsDictionary(motorOutputs)

        let order: [(Int, Double)] = dMotorOutputs.sorted { lhs, rhs in
            Double(lhs.1) > Double(rhs.1)
        }

        var targetShift = AKPoint.zero
        let targetMove = order.first { entry in
            targetShift = Stepper.moves[entry.0]
            return usableOffsets.contains(targetShift)
        }

        guard let tm = targetMove else { return AKPoint.zero }
        return Stepper.moves[tm.0]
    }

    func shift(whereIAmNow: Gridlet) {
        guard let st = stepper else { fatalError() }

        var move = SKAction.run{}
        var flag = SKAction.run{}

        let shiftable = calculateShift(
            from: whereIAmNow,
            previousShift: st.previousShift
        )

        if shiftable {
            let newGridlet = Gridlet.at(whereIAmNow.gridPosition + st.shiftTarget)
            move = SKAction.move(to: newGridlet.scenePosition, duration: 0.1)
            flag = SKAction.run { newGridlet.isEngaged = false }
        }

        let sequence = SKAction.sequence([move, flag])

        st.sprite.run(sequence) {
            st.coordinator.dispatch(.actionComplete_shift)
        }
    }
}
