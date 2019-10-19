import SpriteKit

extension Shift {
    func calculateShift(
        from whereIAmNow: Gridlet, previousShift: AKPoint,
        setShiftTarget: @escaping ShiftTargetCallback,
        completion: @escaping CoordinatorCallback
    ) {
        let workItem = { [weak self] in
            guard let myself = self else { print("bail from calculateShift"); return }
            myself.calculateShift_(whereIAmNow, previousShift, setShiftTarget)
        }

        Lockable<Void>().lock(workItem, completion)
    }

    private func calculateShift_(
        _ whereIAmNow: Gridlet, _ previousShift: AKPoint,
        _ setShiftTarget: ShiftTargetCallback
    ) {
        guard let st = stepper else { print("bail from calculateShift_"); return }

        let senseData = loadSenseData(near: whereIAmNow, previousShift: previousShift)

        st.shiftTarget = selectMoveTarget(
            core: st.core, senseData, usableGridOffsets
        )
//        print("selectMoveTarget() -> \(st.shiftTarget), \(whereIAmNow.gridPosition + st.shiftTarget)")

        releaseGridPoints(whereIAmNow: whereIAmNow, keep: st.shiftTarget)

        setShiftTarget(st.shiftTarget)
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
//        print("rgp keep \(keep ?? AKPoint.zero)")
        let engage = { [unowned self] in
            for gridOffset in self.usableGridOffsets {
//                print("rgp? \(gridOffset)", terminator: "")
                if keep == nil || keep! != gridOffset {
//                    print("!")
                    let targetGridlet =  Gridlet.at(whereIAmNow.gridPosition + gridOffset)
                    targetGridlet.gridletIsEngaged = false
                }// else { print(".") }
            }

            self.usableGridOffsets.removeAll(keepingCapacity: true)
        }

        Lockable<Void>().lock(engage, {})// { print("</rgp>") })
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
}
