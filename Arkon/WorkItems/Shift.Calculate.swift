import SpriteKit

typealias LockAKPoint = Dispatch.Lockable<AKPoint>
extension Shift {
    func calculateShift(
        from whereIAmNow: Gridlet, previousShift: AKPoint,
        setShiftTarget: @escaping LockAKPoint.LockOnComplete,
        onComplete: @escaping LockVoid.LockOnComplete
    ) {
        func workItem() -> [Void]? {
            calculateShift_(whereIAmNow, previousShift, setShiftTarget)
            return nil
        }

        Grid.lock(workItem, onComplete)
    }

    private func calculateShift_(
        _ whereIAmNow: Gridlet, _ previousShift: AKPoint,
        _ setShiftTarget: LockAKPoint.LockOnComplete
    ) {
        guard let st = stepper else {
//            print("bail from calculateShift_")
            return
        }

        let senseData = loadSenseData(near: whereIAmNow, previousShift: previousShift)

        st.shiftTarget = selectMoveTarget(
            core: st.core, senseData, usableGridOffsets
        )
//        print("selectMoveTarget() -> \(st.shiftTarget), \(whereIAmNow.gridPosition + st.shiftTarget)")

        releaseGridPoints(whereIAmNow: whereIAmNow, keep: st.shiftTarget)

        setShiftTarget([st.shiftTarget])
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
        let k: String
        if let kk = keep { k = String(describing: kk) } else { k = "<nil>" }
        print("rgp0 for \(stepper!.core.selectoid.fishNumber); keep \(k)")
        func engage() -> [Void]? {
            guard let st = self.stepper else { print("Bail in rgp"); return nil }
            guard let sel = st.core.selectoid else { fatalError() }

            print("rgp3 for \(sel.fishNumber)")
            for gridOffset in usableGridOffsets {
                print("rgp4 for \(sel.fishNumber)")

                if keep == nil || keep! != gridOffset {
                    print("rgp5 for \(sel.fishNumber)")
                    let targetGridlet =  Gridlet.at(whereIAmNow.gridPosition + gridOffset)
                    print("rg", whereIAmNow.gridPosition, gridOffset, targetGridlet.gridPosition)
                    targetGridlet.gridletIsEngaged = false
                }
                print("rgp7 for \(sel.fishNumber)")
            }

            usableGridOffsets.removeAll(keepingCapacity: true)
            return nil
        }

        print("rgp1 keep \(keep ?? AKPoint.zero)")
        Grid.lock(engage)
        print("rgp2 keep \(keep ?? AKPoint.zero)")
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
